import logging

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .schemas import AskRequest, AskResponse
from .services.llm import LLMError, generate_answer

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="UniTrámite API")

# Permite que Flutter web (Chrome) llame a la API durante el desarrollo.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# PROVISIONAL: se reemplaza por el prompt del RAG en la Tarea 8.
TEST_SYSTEM_PROMPT = "Responde en español, de forma breve y clara."


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/ask", response_model=AskResponse)
def ask(request: AskRequest):
    try:
        text = generate_answer(
            request.question, system_instruction=TEST_SYSTEM_PROMPT
        )
    except LLMError as e:
        raise HTTPException(status_code=503, detail=e.user_message)

    # PROVISIONAL: aún sin documentos, así que el modelo responde con su
    # conocimiento general y puede equivocarse. El prefijo lo advierte.
    return AskResponse(
        answer=f"[PRUEBA SIN DOCUMENTOS] {text}",
        sources=[],
        found=True,
    )