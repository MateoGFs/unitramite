"""Mide qué tan bien la búsqueda encuentra el trámite correcto y calibra el umbral."""
import sys

import numpy as np

from app.rag.embeddings import EmbeddingError, embed_texts
from app.rag.retriever import IndexNotFoundError, get_documents, rank_documents

# Preguntas sin relación con la universidad.
FAR_QUESTIONS = [
    "¿Cuál es la capital de Francia?",
    "Dame una receta de arroz con pollo",
    "¿Quién ganó el último mundial de fútbol?",
    "Escribe un poema sobre el mar",
    "¿Cómo se hace una suma de fracciones?",
]

# Preguntas sobre la universidad que NO están cubiertas por los 7 trámites.
# Son las más difíciles: suenan parecido a un trámite real.
NEAR_QUESTIONS = [
    "¿Cuándo empiezan las clases del próximo semestre?",
    "¿Cómo me inscribo para entrar a la universidad por primera vez?",
    "¿Dónde queda la biblioteca y cuál es su horario?",
    "¿Cómo solicito una beca o un descuento de matrícula?",
    "¿Cómo cambio de carrera?",
]


def main() -> int:
    try:
        documents = get_documents()
    except IndexNotFoundError as e:
        print(e)
        return 1

    in_scope = [
        (doc_id, question)
        for doc_id, doc in documents.items()
        for question in doc["test_questions"]
    ]
    out_scope = [("lejana", q) for q in FAR_QUESTIONS] + [
        ("cercana", q) for q in NEAR_QUESTIONS
    ]

    all_questions = [q for _, q in in_scope] + [q for _, q in out_scope]
    print(f"Generando embeddings de {len(all_questions)} preguntas...")
    try:
        vectors = embed_texts(all_questions, task_type="RETRIEVAL_QUERY")
    except EmbeddingError as e:
        print("ERROR:", e.user_message)
        return 1

    try:
        ranked = [rank_documents(v) for v in vectors]
    except IndexNotFoundError as e:
        print(e)
        return 1
    n_in = len(in_scope)

    top1 = top2 = 0
    in_scores: list[float] = []
    print("\n=== Preguntas de prueba de cada trámite ===")
    for (expected, question), result in zip(in_scope, ranked[:n_in]):
        first, second = result[0], result[1]
        ok1 = first.doc_id == expected
        ok2 = expected in (first.doc_id, second.doc_id)
        top1 += ok1
        top2 += ok2
        in_scores.append(first.score)
        tag = "OK   " if ok1 else ("2.o  " if ok2 else "FALLA")
        extra = ""
        if not ok1:
            expected_score = next(m.score for m in result if m.doc_id == expected)
            extra = (
                f"  -> obtuvo {first.doc_id} ({first.score:.3f}), "
                f"esperado {expected} ({expected_score:.3f})"
            )
        print(f"{tag} {first.score:.3f} {expected} | {question}{extra}")

    out_scores: list[float] = []
    print("\n=== Preguntas fuera de alcance (no deben pasar el umbral) ===")
    for (kind, question), result in zip(out_scope, ranked[n_in:]):
        first = result[0]
        out_scores.append(first.score)
        print(f"{kind:7} {first.score:.3f} {first.doc_id} | {question}")

    in_arr = np.array(in_scores)
    out_arr = np.array(out_scores)
    p10 = float(np.percentile(in_arr, 10))

    print("\n=== Resumen ===")
    print(f"Acierto en el 1.er lugar:       {top1}/{n_in}")
    print(f"Acierto entre los 2 primeros:   {top2}/{n_in}")
    print(
        "Puntaje del 1.er lugar, preguntas de trámites:      "
        f"mín {in_arr.min():.3f} | p10 {p10:.3f} | mediana {np.median(in_arr):.3f}"
    )
    print(
        "Puntaje del 1.er lugar, preguntas fuera de alcance: "
        f"mediana {np.median(out_arr):.3f} | máx {out_arr.max():.3f}"
    )

    if p10 > out_arr.max():
        print(f"\nUmbral sugerido: {(p10 + out_arr.max()) / 2:.3f}")
    else:
        print(
            "\nLos puntajes se superponen: un umbral solo no separa bien los dos "
            "grupos. Lo complementaremos con las instrucciones del prompt."
        )

    low = [
        (q, s)
        for (_, q), s in zip(in_scope, in_scores)
        if s <= out_arr.max()
    ]
    if low:
        print("\nPreguntas de trámites con puntaje igual o menor al máximo de las ajenas:")
        for q, s in low:
            print(f"  {s:.3f} | {q}")

    return 0


if __name__ == "__main__":
    sys.exit(main())