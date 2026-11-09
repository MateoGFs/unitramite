import logging

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .rag.answering import answer_question
from .schemas import AskRequest, AskResponse, Source
from .services.llm import LLMError

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="UniTrámite API")

# Permite que Flutter web (Chrome) llame a la API durante el desarrollo.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/ask", response_model=AskResponse)
def ask(request: AskRequest):
    try:
        result = answer_question(request.question)
    except LLMError as e:
        raise HTTPException(status_code=503, detail=e.user_message)

    return AskResponse(
        answer=result.answer,
        found=result.found,
        sources=[Source(document_name=s.title, url=s.url) for s in result.sources],
    )