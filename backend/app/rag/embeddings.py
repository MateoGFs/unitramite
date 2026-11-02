"""Generación de embeddings con Gemini."""
import logging
import time

import numpy as np
from google import genai
from google.genai import errors, types

from ..config import EMBEDDING_DIM, GEMINI_API_KEY, GEMINI_EMBEDDING_MODEL

logger = logging.getLogger("unitramite.embeddings")

BATCH_SIZE = 20
MAX_RETRIES = 4
RETRYABLE_CODES = {429, 500, 502, 503, 504}

_client = genai.Client(api_key=GEMINI_API_KEY) if GEMINI_API_KEY else None


class EmbeddingError(Exception):
    """Fallo al generar embeddings, con un mensaje legible."""

    def __init__(self, user_message: str):
        super().__init__(user_message)
        self.user_message = user_message


def _embed_batch(texts: list[str], task_type: str) -> list[list[float]]:
    if _client is None:
        raise EmbeddingError("Falta GEMINI_API_KEY en backend/.env")

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            result = _client.models.embed_content(
                model=GEMINI_EMBEDDING_MODEL,
                contents=texts,
                config=types.EmbedContentConfig(
                    task_type=task_type,
                    output_dimensionality=EMBEDDING_DIM,
                ),
            )
            return [list(e.values) for e in result.embeddings]
        except errors.APIError as e:
            retryable = e.code in RETRYABLE_CODES
            logger.warning("Embeddings: error %s (intento %d/%d)", e.code, attempt, MAX_RETRIES)
            if retryable and attempt < MAX_RETRIES:
                time.sleep(10 * attempt)
                continue
            raise EmbeddingError(
                f"La API de embeddings respondió con error {e.code}: {e}"
            ) from e
        except Exception as e:
            raise EmbeddingError(f"No se pudo generar embeddings: {e}") from e

    raise EmbeddingError("No se pudo generar embeddings tras varios intentos.")


def embed_texts(texts: list[str], task_type: str = "RETRIEVAL_DOCUMENT") -> np.ndarray:
    """Devuelve una matriz (n, dimensiones) con vectores normalizados."""
    vectors: list[list[float]] = []
    for i in range(0, len(texts), BATCH_SIZE):
        vectors.extend(_embed_batch(texts[i : i + BATCH_SIZE], task_type))
        time.sleep(1)  # pausa corta para no chocar con límites por minuto

    matrix = np.array(vectors, dtype=np.float32)
    norms = np.linalg.norm(matrix, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    return matrix / norms