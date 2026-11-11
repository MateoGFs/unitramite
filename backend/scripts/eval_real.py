"""Prueba con preguntas reales: lenguaje informal, contexto personal y casos difíciles."""
import sys
import time

from app.rag.answering import answer_question
from app.rag.retriever import IndexNotFoundError, get_documents, search, select_matches

PAUSE_SECONDS = 3

# (pregunta, trámite esperado)
QUESTIONS = [
    # --- Escritas por compañeros
    ("Holi, hasme un fa quiero saber cómo canceló el semestre, estoy cursando octavo semestre de ingeniería agroindustrial en la universidad de Nariño, dime todo lo que necesito y que hacer", "TR-005"),
    ("Cómo hago para cancelar un semestre de la universidad de Nariño ?", "TR-005"),
    ("Cómo puedo sacar un certificado de estudios de la universidad de Nariño de manera virtual?", "TR-001"),
    ("Ayúdame paso a paso a  cancelar el semestre de la universidad correctamente", "TR-005"),
    ("Holi, quiero mi certificado de estudios de la universidad de Nariño, me dices que necesito para sacarlo y que debería contener", "TR-001"),
    ("Ayúdame a conseguir un certificado de estudios universitarios de manera directa", "TR-001"),
    # --- Casos difíciles agregados
    ("q kiero cancelar mi semestre xq tengo problemas de salud, q hago", "TR-005"),
    ("necesito un papel que diga que estudio aca para llevarlo al banco", "TR-001"),
    ("voy a prestar el servicio militar y no quiero perder mi cupo, que hago", "TR-007"),
    ("quiero graduarme el otro año, que tengo que hacer", "TR-004"),
    ("ya pase todas las materias pero no he presentado ingles, me puedo graduar?", "TR-004"),
    ("puedo cancelar el semestre solo porque no me va bien o tiene que ser por una razon grave?", "TR-005"),
    ("estoy en octavo semestre y voy a prestar el servicio militar, puedo reservar el cupo?", "TR-007"),
    ("¿qué datos trae la constancia de matrícula?", "TR-001"),
]


def main() -> int:
    try:
        get_documents()
    except IndexNotFoundError as e:
        print(e)
        return 1

    ok = review = errors = 0
    for question, expected in QUESTIONS:
        try:
            matches = search(question)
            sent = [m.doc_id for m in select_matches(matches)]
            result = answer_question(question)
        except Exception as e:  # script de prueba: mostramos cualquier fallo
            errors += 1
            print(f"ERROR   {question}\n        {e}\n")
            time.sleep(PAUSE_SECONDS)
            continue

        good = bool(matches) and matches[0].doc_id == expected and result.found
        ok += good
        review += not good
        tag = "OK     " if good else "REVISAR"
        top = ", ".join(f"{m.doc_id} {m.score:.2f}" for m in matches[:3])
        print(f"{tag} esperado={expected} | mejores: {top} | enviados: {sent}")
        print(f"        PREGUNTA: {question}")
        print("        RESPUESTA:")
        for line in result.answer.splitlines():
            print("          " + line)
        print()
        time.sleep(PAUSE_SECONDS)

    print(f"Resumen: {ok} OK | {review} por revisar | {errors} con error (de {len(QUESTIONS)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())