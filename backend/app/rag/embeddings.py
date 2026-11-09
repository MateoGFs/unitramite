"""Generación de embeddings con Gemini."""
import logging
import time

import numpy as np
from google import genai
from google.genai import errors, types

from ..config import EMBEDDING_DIM, GEMINI_API_KEY, GEMINI_EMBEDDING_MODEL

logger = logging.getLogger("unitramite.embeddings")

BATCH_SIZE = 20
TIMEOUT_MS = 30_000
RETRYABLE_CODES = {429, 500, 502, 503, 504}

_client = (
    genai.Client(
        api_key=GEMINI_API_KEY,
        http_options=types.HttpOptions(timeout=TIMEOUT_MS),
    )
    if GEMINI_API_KEY
    else None
)


class EmbeddingError(Exception):
    """Fallo al generar embeddings, con un mensaje legible."""

    def __init__(self, user_message: str):
        super().__init__(user_message)
        self.user_message = user_message


def _embed_batch(
    texts: list[str], task_type: str, max_retries: int, retry_delay: float
) -> list[list[float]]:
    if _client is None:
        raise EmbeddingError("Falta GEMINI_API_KEY en backend/.env")

    last_error: Exception | None = None
    for attempt in range(1, max_retries + 1):
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
        except Exception as e:
            last_error = e
            if isinstance(e, errors.APIError):
                retryable = e.code in RETRYABLE_CODES
            else:
                retryable = True  # fallos de red o tiempo agotado
            logger.warning(
                "Embeddings: fallo (intento %d/%d): %s", attempt, max_retries, e
            )
            if retryable and attempt < max_retries:
                time.sleep(retry_delay * attempt)
                continue
            break

    raise EmbeddingError(f"No se pudo generar embeddings: {last_error}")


def embed_texts(
    texts: list[str],
    task_type: str = "RETRIEVAL_DOCUMENT",
    max_retries: int = 4,
    retry_delay: float = 10.0,
) -> np.ndarray:
    """Devuelve una matriz (n, dimensiones) con vectores normalizados."""
    vectors: list[list[float]] = []
    for i in range(0, len(texts), BATCH_SIZE):
        if i > 0:
            time.sleep(1)  # pausa corta para no chocar con límites por minuto
        vectors.extend(
            _embed_batch(texts[i : i + BATCH_SIZE], task_type, max_retries, retry_delay)
        )

    matrix = np.array(vectors, dtype=np.float32)
    norms = np.linalg.norm(matrix, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    return matrix / norms