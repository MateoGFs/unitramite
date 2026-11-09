"""Prueba de punta a punta del RAG: pregunta -> búsqueda -> IA -> respuesta.

Uso:
  python -m scripts.eval_answers          (2 preguntas por trámite + las ajenas)
  python -m scripts.eval_answers --all    (todas las preguntas de prueba)
"""
import sys
import time

from app.rag.answering import answer_question
from app.rag.retriever import IndexNotFoundError, get_documents
from app.services.llm import LLMError
from scripts.eval_retrieval import FAR_QUESTIONS, NEAR_QUESTIONS

PAUSE_SECONDS = 3  # evita chocar con los límites de uso del nivel gratuito


def main() -> int:
    run_all = "--all" in sys.argv
    try:
        documents = get_documents()
    except IndexNotFoundError as e:
        print(e)
        return 1

    cases: list[tuple[bool, str, str]] = []
    for doc_id, doc in documents.items():
        questions = doc["test_questions"] if run_all else doc["test_questions"][:2]
        cases += [(True, doc_id, q) for q in questions]
    cases += [(False, "lejana", q) for q in FAR_QUESTIONS]
    cases += [(False, "cercana", q) for q in NEAR_QUESTIONS]

    ok = review = errors = 0
    for expected, label, question in cases:
        try:
            result = answer_question(question)
        except LLMError as e:
            errors += 1
            print(f"ERROR   [{label}] {question}\n        {e.user_message}\n")
            time.sleep(PAUSE_SECONDS)
            continue

        good = result.found == expected
        ok += good
        review += not good
        tag = "OK     " if good else "REVISAR"
        print(f"{tag} [{label}] found={result.found} | {question}")
        print("        " + result.answer.replace("\n", " ")[:350])
        if result.sources:
            print("        fuentes:", " | ".join(s.title for s in result.sources[:3]))
        print()
        time.sleep(PAUSE_SECONDS)

    print(f"Resumen: {ok} OK | {review} por revisar | {errors} con error (de {len(cases)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())