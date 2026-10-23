import logging
import time

from google import genai
from google.genai import errors, types

from ..config import (
    GEMINI_API_KEY,
    GEMINI_FALLBACK_MODEL,
    GEMINI_MODEL,
    GEMINI_TIMEOUT_SECONDS,
)

logger = logging.getLogger("unitramite.llm")

# Códigos que suelen ser temporales: vale la pena reintentar.
RETRYABLE_CODES = {429, 500, 502, 503, 504}
BACKOFF_SECONDS = 1.5


class LLMError(Exception):
    """Fallo al consultar la IA, con un mensaje apto para mostrar al usuario."""

    def __init__(self, user_message: str):
        super().__init__(user_message)
        self.user_message = user_message


_client = (
    genai.Client(
        api_key=GEMINI_API_KEY,
        http_options=types.HttpOptions(timeout=int(GEMINI_TIMEOUT_SECONDS * 1000)),
    )
    if GEMINI_API_KEY
    else None
)


def _is_retryable(error: Exception) -> bool:
    if isinstance(error, errors.APIError):
        return error.code in RETRYABLE_CODES
    return True  # fallos de red o tiempo agotado


def _to_llm_error(error: Exception | None) -> LLMError:
    if isinstance(error, errors.APIError):
        if error.code == 429:
            return LLMError(
                "El servicio de IA está recibiendo muchas solicitudes. "
                "Espera un momento e intenta de nuevo."
            )
        if error.code in (500, 502, 503, 504):
            return LLMError(
                "El servicio de IA está saturado en este momento. "
                "Intenta de nuevo en unos segundos."
            )
        return LLMError("El servicio de IA no pudo responder en este momento.")
    return LLMError(
        "No se pudo comunicar con el servicio de IA. Intenta de nuevo."
    )


def _call_model(model: str, prompt: str, system_instruction: str | None) -> str:
    response = _client.models.generate_content(
        model=model,
        contents=prompt,
        config=types.GenerateContentConfig(
            system_instruction=system_instruction,
            temperature=0.2,
        ),
    )
    return (response.text or "").strip()


def generate_answer(prompt: str, system_instruction: str | None = None) -> str:
    """Genera una respuesta con reintentos y modelo de respaldo."""
    if _client is None:
        raise LLMError("El servicio de IA no está configurado en el servidor.")

    models = [GEMINI_MODEL]
    if GEMINI_FALLBACK_MODEL and GEMINI_FALLBACK_MODEL != GEMINI_MODEL:
        models.append(GEMINI_FALLBACK_MODEL)

    last_error: Exception | None = None

    for index, model in enumerate(models):
        attempts = 2 if index == 0 else 1  # el respaldo se intenta una sola vez
        for attempt in range(1, attempts + 1):
            try:
                text = _call_model(model, prompt, system_instruction)
            except Exception as e:
                last_error = e
                logger.warning(
                    "Fallo con %s (intento %d/%d): %s", model, attempt, attempts, e
                )
                if not _is_retryable(e):
                    break  # no tiene sentido reintentar; pasar al siguiente modelo
                if attempt < attempts:
                    time.sleep(BACKOFF_SECONDS)
                continue

            if not text:
                raise LLMError(
                    "El servicio de IA no devolvió una respuesta. "
                    "Intenta reformular tu pregunta."
                )
            if index > 0:
                logger.info("Respuesta obtenida con el modelo de respaldo %s", model)
            return text

    raise _to_llm_error(last_error) from last_error