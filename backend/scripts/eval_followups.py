"""Prueba preguntas de seguimiento: la conversación completa, de punta a punta."""
import sys
import time

from app.rag.answering import answer_question
from app.rag.retriever import IndexNotFoundError, get_documents
from app.schemas import ChatTurn
from app.services.llm import LLMError

PAUSE_SECONDS = 3

SCENARIOS = [
    {
        "name": "Costo de constancias (seguimiento)",
        "turns": ["¿Cómo saco un certificado de estudios?", "¿Y cuánto cuesta?"],
        "expect_found": True,
        "expect_text": "16.100",
    },
    {
        "name": "Costo de cancelación (seguimiento)",
        "turns": ["¿Cómo cancelo el semestre?", "¿y cuánto vale eso?"],
        "expect_found": True,
        "expect_text": "4.100",
    },
    {
        "name": "Costo del PIN de reingreso (seguimiento)",
        "turns": ["¿Cómo retomo mi carrera si ya tenía reserva de cupo?", "¿Cuánto cuesta el PIN?"],
        "expect_found": True,
        "expect_text": "38.700",
    },
    {
        "name": "Cambio de tema",
        "turns": ["¿Cómo cancelo el semestre?", "Ahora quiero homologar materias de otra universidad"],
        "expect_found": True,
        "expect_text": "homolog",
    },
    {
        "name": "Seguimiento fuera de alcance",
        "turns": ["¿Cómo saco un certificado de estudios?", "¿Y cuál es la capital de Francia?"],
        "expect_found": False,
        "expect_text": None,
    },
    {
        "name": "Seguimiento por sede (revisar a mano)",
        "turns": ["¿Cómo saco un certificado de estudios?", "¿Puedo pedirlo si estudio en Tumaco?"],
        "expect_found": None,
        "expect_text": None,
    },
]


def main() -> int:
    try:
        get_documents()
    except IndexNotFoundError as e:
        print(e)
        return 1

    ok = review = errors = 0
    for scenario in SCENARIOS:
        history: list[ChatTurn] = []
        result = None
        failed = False
        for question in scenario["turns"]:
            try:
                result = answer_question(question, history)
            except LLMError as e:
                print(f"ERROR   [{scenario['name']}] {e.user_message}\n")
                errors += 1
                failed = True
                break
            history.append(ChatTurn(role="user", text=question))
            history.append(ChatTurn(role="assistant", text=result.answer[:800]))
            time.sleep(PAUSE_SECONDS)
        if failed or result is None:
            continue

        good = True
        if scenario["expect_found"] is not None and result.found != scenario["expect_found"]:
            good = False
        if scenario["expect_text"] and scenario["expect_text"].lower() not in result.answer.lower():
            good = False

        manual = scenario["expect_found"] is None
        tag = "MANUAL " if manual else ("OK     " if good else "REVISAR")
        if not manual:
            ok += good
            review += not good
        print(f"{tag} [{scenario['name']}] found={result.found}")
        print("        " + " -> ".join(scenario["turns"]))
        print("        " + result.answer.replace("\n", " ")[:400])
        print()

    print(f"Resumen: {ok} OK | {review} por revisar | {errors} con error")
    return 0


if __name__ == "__main__":
    sys.exit(main())