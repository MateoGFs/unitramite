"""Búsqueda de los trámites más relevantes para una pregunta."""
import json
from dataclasses import dataclass
from functools import lru_cache

import numpy as np

from ..config import INDEX_PATH, MAX_DOCS, MIN_SIMILARITY, SCORE_MARGIN
from .embeddings import embed_texts


class IndexNotFoundError(Exception):
    """El índice no existe o no coincide con la configuración actual."""


@dataclass
class DocMatch:
    doc_id: str
    score: float
    best_section: str


@lru_cache(maxsize=1)
def _load() -> tuple[dict, np.ndarray, dict[str, dict]]:
    if not INDEX_PATH.exists():
        raise IndexNotFoundError(
            "No existe el índice. Ejecuta primero: python -m scripts.ingest"
        )
    index = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    matrix = np.array([c["embedding"] for c in index["chunks"]], dtype=np.float32)
    documents = {d["id"]: d for d in index["documents"]}
    return index, matrix, documents


def reload_index() -> None:
    """Fuerza a releer el índice (por ejemplo, tras volver a ingestar)."""
    _load.cache_clear()


def get_documents() -> dict[str, dict]:
    """Trámites indexados, por id."""
    return _load()[2]


def rank_documents(query_vector: np.ndarray) -> list[DocMatch]:
    """Ordena los trámites por similitud; cada uno vale lo que su mejor fragmento."""
    index, matrix, _ = _load()
    if matrix.shape[1] != len(query_vector):
        raise IndexNotFoundError(
            "Las dimensiones del índice no coinciden con las de la consulta. "
            "Vuelve a ejecutar: python -m scripts.ingest"
        )

    scores = matrix @ query_vector  # vectores normalizados: producto punto = coseno
    best: dict[str, DocMatch] = {}
    for chunk, score in zip(index["chunks"], scores):
        current = best.get(chunk["doc_id"])
        if current is None or float(score) > current.score:
            best[chunk["doc_id"]] = DocMatch(
                doc_id=chunk["doc_id"],
                score=float(score),
                best_section=chunk["section"],
            )
    return sorted(best.values(), key=lambda m: m.score, reverse=True)


def search(question: str) -> list[DocMatch]:
    """Embebe la pregunta y devuelve los trámites ordenados por relevancia."""
    vector = embed_texts(
        [question], task_type="RETRIEVAL_QUERY", max_retries=2, retry_delay=1.5
    )[0]
    return rank_documents(vector)


def select_matches(matches: list[DocMatch]) -> list[DocMatch]:
    """Trámites que se le entregan a la IA: los relevantes y cercanos al mejor."""
    if not matches or matches[0].score < MIN_SIMILARITY:
        return []
    best = matches[0].score
    return [
        m
        for m in matches[:MAX_DOCS]
        if m.score >= MIN_SIMILARITY and m.score >= best - SCORE_MARGIN
    ]