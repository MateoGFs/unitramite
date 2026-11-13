"""Catálogo de trámites para la app: datos estructurados leídos de los .md (sin IA)."""
import logging
import re
from functools import lru_cache

from ..config import DOCS_DIR
from ..schemas import Source, TramiteDetail, TramiteSummary
from .loader import Tramite, _find_section, load_all  # _find_section: uso interno del paquete

logger = logging.getLogger("unitramite.catalog")

_ITEM_RE = re.compile(r"^\s*(?:[-*]|\d+[.)])\s+(.+?)\s*$")


def _items(text: str) -> list[str]:
    """Viñetas o pasos numerados de una sección, una cadena por elemento."""
    items: list[str] = []
    for line in text.splitlines():
        match = _ITEM_RE.match(line)
        if match:
            items.append(match.group(1))
    return items


def _section(tramite: Tramite, *names: str) -> str:
    key = _find_section(tramite.sections, list(names))
    return tramite.sections.get(key, "") if key else ""


def _first_paragraph(text: str) -> str:
    return text.strip().split("\n\n")[0].replace("\n", " ").strip()


@lru_cache(maxsize=1)
def _load() -> dict[str, Tramite]:
    tramites, errors = load_all(DOCS_DIR)
    for name, problems in errors.items():
        logger.warning("Trámite omitido del catálogo (%s): %s", name, problems)
    return {t.id: t for t in tramites}


def reload_catalog() -> None:
    _load.cache_clear()


def _summary(t: Tramite) -> TramiteSummary:
    return TramiteSummary(
        id=t.id,
        nombre=t.nombre,
        categoria=t.categoria,
        descripcion=_first_paragraph(_section(t, "Descripción sencilla")),
    )


def _detail(t: Tramite) -> TramiteDetail:
    return TramiteDetail(
        **_summary(t).model_dump(),
        requisitos=_items(_section(t, "Requisitos")),
        pasos=_items(_section(t, "Pasos")),
        condiciones=_items(_section(t, "Condiciones")),
        referencia=_items(
            _section(t, "Información susceptible", "Información no confirmada")
        ),
        dependencia=t.dependencia,
        contacto=t.contacto,
        fecha_verificacion=t.fecha_verificacion,
        # Se sugieren las preguntas de prueba, que ya están comprobadas.
        preguntas=(t.test_questions or _items(_section(t, "Intenciones")))[:3],
        fuentes=[Source(document_name=s.title, url=s.url) for s in t.sources],
    )


def list_summaries() -> list[TramiteSummary]:
    return [_summary(t) for _, t in sorted(_load().items())]


def get_detail(tramite_id: str) -> TramiteDetail | None:
    tramite = _load().get(tramite_id)
    return _detail(tramite) if tramite else None