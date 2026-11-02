"""Búsqueda de prueba: muestra los fragmentos más parecidos a una pregunta."""
import json
import sys

import numpy as np

from app.config import INDEX_PATH
from app.rag.embeddings import EmbeddingError, embed_texts


def main() -> int:
    question = " ".join(sys.argv[1:]).strip()
    if not question:
        print('Uso: python -m scripts.search_test "tu pregunta"')
        return 1
    if not INDEX_PATH.exists():
        print("Primero ejecuta: python -m scripts.ingest")
        return 1

    index = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    matrix = np.array([c["embedding"] for c in index["chunks"]], dtype=np.float32)

    try:
        query = embed_texts([question], task_type="RETRIEVAL_QUERY")[0]
    except EmbeddingError as e:
        print("ERROR:", e.user_message)
        return 1

    scores = matrix @ query  # vectores normalizados: producto punto = similitud coseno
    print(f"Pregunta: {question}\n")
    for i in np.argsort(-scores)[:5]:
        chunk = index["chunks"][i]
        print(f"{scores[i]:.3f}  [{chunk['doc_id']}] {chunk['section']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())