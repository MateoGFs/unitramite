"""Lectura, validación y fragmentación de los trámites escritos en Markdown."""
import re
import unicodedata
from dataclasses import dataclass, field
from pathlib import Path


def _norm(text: str) -> str:
    """Minúsculas y sin tildes, para comparar nombres."""
    text = unicodedata.normalize("NFD", text)
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")
    return text.lower().strip()


def _clean(raw: str) -> str:
    """Limpia restos de exportaciones: comentarios, escapes y enlaces mailto."""
    raw = re.sub(r"<!--.*?-->", "", raw, flags=re.DOTALL)
    raw = re.sub(r"\\([\\`*_{}\[\]()#+\-.!$<>|~])", r"\1", raw)
    raw = re.sub(r"\[([^\]]+)\]\(mailto:[^)\s]+\)", r"\1", raw)
    return raw


REQUIRED_FIELDS = [
    "id",
    "nombre",
    "categoria",
    "estado",
    "dependencia_responsable",
    "fecha_verificacion",
]

# Cada sección obligatoria acepta varios nombres (sin tildes, por prefijo).
REQUIRED_SECTIONS = {
    "Descripción sencilla": ["Descripción sencilla"],
    "Requisitos": ["Requisitos"],
    "Pasos": ["Pasos"],
    "Fuentes oficiales": ["Fuentes oficiales"],
}

# Secciones que NO se indexan. Las preguntas de prueba son el "examen" del
# sistema: si se indexaran, la app tendría las respuestas a la vista.
INDEX_EXCLUDED_PREFIXES = [
    _norm(s) for s in ["Preguntas de prueba", "Respuesta segura", "Fuentes oficiales"]
]
# Secciones que no se envían al modelo como contexto.
LLM_EXCLUDED_PREFIXES = INDEX_EXCLUDED_PREFIXES + [_norm("Intenciones")]

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
SOURCE_RE = re.compile(r"\[([^\]]+)\]\((https?://[^)\s]+)\)")
QUESTION_RE = re.compile(r"^\s*(?:\d+[.)]|[-*])\s*(.+?)\s*$")
MAX_CHARS = 1200  # tamaño máximo de un fragmento


def _matches(name: str, prefixes: list[str]) -> bool:
    n = _norm(name)
    return any(n.startswith(p) for p in prefixes)


def _find_section(sections: dict[str, str], names: list[str]) -> str | None:
    """Devuelve el nombre real de la primera sección que coincida con alguno."""
    prefixes = [_norm(n) for n in names]
    for name in sections:
        if _matches(name, prefixes):
            return name
    return None


@dataclass
class Source:
    title: str
    url: str


@dataclass
class Tramite:
    id: str
    nombre: str
    categoria: str
    estado: str
    dependencia: str
    fecha_verificacion: str
    contacto: str
    path: str
    sections: dict[str, str]
    sources: list[Source] = field(default_factory=list)
    test_questions: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def llm_text(self) -> str:
        """Texto completo del trámite que se le dará al modelo como contexto."""
        parts = [
            f"TRÁMITE: {self.nombre}",
            f"Categoría: {self.categoria}",
            f"Dependencia responsable: {self.dependencia}",
            f"Fecha de verificación de la información: {self.fecha_verificacion}",
        ]
        if self.contacto:
            parts.append(f"Contacto: {self.contacto}")
        for name, text in self.sections.items():
            if _matches(name, LLM_EXCLUDED_PREFIXES) or not text:
                continue
            parts.append(f"\n## {name}\n{text}")
        return "\n".join(parts)

    def to_document(self) -> dict:
        return {
            "id": self.id,
            "nombre": self.nombre,
            "categoria": self.categoria,
            "estado": self.estado,
            "dependencia": self.dependencia,
            "fecha_verificacion": self.fecha_verificacion,
            "contacto": self.contacto,
            "sources": [{"title": s.title, "url": s.url} for s in self.sources],
            "test_questions": self.test_questions,
            "llm_text": self.llm_text(),
        }


class TramiteError(Exception):
    def __init__(self, problems: list[str]):
        super().__init__("; ".join(problems))
        self.problems = problems


def parse_tramite(path: Path) -> Tramite:
    raw = _clean(path.read_text(encoding="utf-8-sig"))
    lines = raw.strip().splitlines()
    problems: list[str] = []

    # --- Encabezado entre dos líneas '---'
    meta: dict[str, str] = {}
    body_start = 0
    header_ok = False
    if not lines or lines[0].strip() != "---":
        problems.append("El archivo debe empezar con una línea '---' (encabezado).")
    else:
        end = next(
            (i for i in range(1, len(lines)) if lines[i].strip() == "---"), None
        )
        if end is None:
            if any(re.match(r"^#+\s*id\s*:", line, re.I) for line in lines[:5]):
                problems.append(
                    "El encabezado quedó convertido en un título ('## id: ...'). "
                    "Suele pasar al editar en Google Docs o Word. Debe ser un bloque "
                    "entre dos líneas '---', con un campo por línea."
                )
            else:
                problems.append("Falta la línea '---' que cierra el encabezado.")
        else:
            for line in lines[1:end]:
                if ":" in line:
                    key, value = line.split(":", 1)
                    meta[_norm(key)] = value.strip()
            body_start = end + 1
            header_ok = True

    if header_ok:
        for name in REQUIRED_FIELDS:
            if not meta.get(name):
                problems.append(f"Falta el campo '{name}' en el encabezado.")
        date = meta.get("fecha_verificacion", "")
        if date and not DATE_RE.match(date):
            problems.append(
                f"fecha_verificacion debe ser AAAA-MM-DD (dice '{date}')."
            )

    # --- Secciones '## Título'
    sections: dict[str, str] = {}
    current: str | None = None
    buffer: list[str] = []
    for line in lines[body_start:]:
        match = re.match(r"^##\s+(.+?)\s*$", line)
        if match:
            if current is not None:
                sections[current] = "\n".join(buffer).strip()
            current = match.group(1)
            buffer = []
        elif current is not None:
            buffer.append(line)
    if current is not None:
        sections[current] = "\n".join(buffer).strip()

    for label, names in REQUIRED_SECTIONS.items():
        key = _find_section(sections, names)
        if key is None:
            problems.append(f"Falta la sección '## {label}' (o una equivalente).")
        elif not sections[key]:
            problems.append(f"La sección '## {key}' está vacía.")

    # --- Fuentes: enlaces [Título](URL)
    sources: list[Source] = []
    sources_key = _find_section(sections, ["Fuentes oficiales"])
    if sources_key:
        sources = [
            Source(title.strip(), url)
            for title, url in SOURCE_RE.findall(sections[sources_key])
        ]
        if not sources:
            problems.append(
                f"'## {sources_key}' no tiene enlaces con el formato [Título](URL)."
            )

    # --- Preguntas de prueba
    questions: list[str] = []
    questions_key = _find_section(sections, ["Preguntas de prueba"])
    if questions_key:
        for line in sections[questions_key].splitlines():
            match = QUESTION_RE.match(line)
            if match:
                questions.append(match.group(1))

    if problems:
        raise TramiteError(problems)

    warnings: list[str] = []
    if not path.name.startswith(meta["id"]):
        warnings.append(f"El nombre del archivo no empieza con su id ({meta['id']}).")
    if not questions:
        warnings.append("No tiene preguntas de prueba.")

    return Tramite(
        id=meta["id"],
        nombre=meta["nombre"],
        categoria=meta["categoria"],
        estado=meta["estado"],
        dependencia=meta["dependencia_responsable"],
        fecha_verificacion=meta["fecha_verificacion"],
        contacto=meta.get("contacto", ""),
        path=path.name,
        sections=sections,
        sources=sources,
        test_questions=questions,
        warnings=warnings,
    )


def load_all(docs_dir: Path) -> tuple[list[Tramite], dict[str, list[str]]]:
    """Lee todos los .md. Devuelve (trámites válidos, errores por archivo)."""
    tramites: list[Tramite] = []
    errors: dict[str, list[str]] = {}
    seen: dict[str, str] = {}

    for path in sorted(docs_dir.glob("*.md")):
        try:
            tramite = parse_tramite(path)
        except TramiteError as e:
            errors[path.name] = e.problems
            continue
        if tramite.id in seen:
            errors[path.name] = [f"El id {tramite.id} ya lo usa {seen[tramite.id]}."]
            continue
        seen[tramite.id] = path.name
        tramites.append(tramite)

    return tramites, errors


def _split(text: str, max_chars: int) -> list[str]:
    if len(text) <= max_chars:
        return [text]
    parts: list[str] = []
    current = ""
    for line in text.splitlines():
        if current and len(current) + len(line) + 1 > max_chars:
            parts.append(current.strip())
            current = ""
        current += line + "\n"
    if current.strip():
        parts.append(current.strip())
    return parts


def build_chunks(tramite: Tramite) -> list[dict]:
    """Un fragmento por sección (o más, si es muy larga), con el trámite al inicio."""
    chunks: list[dict] = []
    for name, text in tramite.sections.items():
        if _matches(name, INDEX_EXCLUDED_PREFIXES) or not text:
            continue
        for part in _split(text, MAX_CHARS):
            chunks.append(
                {
                    "doc_id": tramite.id,
                    "section": name,
                    "text": f"{tramite.nombre} - {name}\n{part}",
                }
            )
    return chunks