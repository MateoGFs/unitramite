from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .schemas import AskRequest, AskResponse, Source

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
    # Provisional: aquí irá el RAG con IA.
    return AskResponse(
        answer=(
            "Respuesta de PRUEBA desde el backend. "
            f"Recibí tu pregunta: «{request.question}»."
        ),
        sources=[Source(document_name="Documento de prueba del backend", page=1)],
        found=True,
    )