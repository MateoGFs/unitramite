"""Revisa que cada 'intención' de los trámites tenga respuesta en su contenido."""
import re
import sys
import time

from app.config import DOCS_DIR
from app.rag.answering import answer_question
from app.rag.loader import _find_section, load_all  # uso interno, solo para QA
from app.services.llm import LLMError

PAUSE_SECONDS = 3
ITEM_RE = re.compile(r"^\s*(?:[-*]|\d+[.)])\s+(.+?)\s*$")


def intents(tramite) -> list[str]:
    key = _find_section(tramite.sections, ["Intenciones"])
    if not key:
        return []
    found = []
    for line in tramite.sections[key].splitlines():
        match = ITEM_RE.match(line)
        if match:
            found.append(match.group(1))
    return found


def main() -> int:
    tramites, _ = load_all(DOCS_DIR)
    total = gaps = errors = 0

    for tramite in tramites:
        for question in intents(tramite):
            total += 1
            try:
                result = answer_question(question)
            except LLMError as e:
                errors += 1
                print(f"ERROR          [{tramite.id}] {question}\n               {e.user_message}")
                time.sleep(PAUSE_SECONDS)
                continue
            if not result.found:
                gaps += 1
                print(f"SIN RESPUESTA  [{tramite.id}] {question}")
            time.sleep(PAUSE_SECONDS)

    print(f"\nResumen: {total - gaps - errors} con respuesta | {gaps} sin respuesta | {errors} con error (de {total})")
    if gaps:
        print("Las 'SIN RESPUESTA' son preguntas que el trámite promete pero su contenido no cubre.")
    return 0


if __name__ == "__main__":
    sys.exit(main())