from typing import Literal

from pydantic import BaseModel, Field


class ChatTurn(BaseModel):
    role: Literal["user", "assistant"]
    text: str = Field(max_length=1500)


class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=1000)
    history: list[ChatTurn] = Field(default_factory=list, max_length=8)


class Source(BaseModel):
    document_name: str
    page: int | None = None
    url: str | None = None


class AskResponse(BaseModel):
    answer: str
    sources: list[Source] = []
    found: bool = True


class TramiteSummary(BaseModel):
    id: str
    nombre: str
    categoria: str
    descripcion: str


class TramiteDetail(TramiteSummary):
    requisitos: list[str] = []
    pasos: list[str] = []
    condiciones: list[str] = []
    referencia: list[str] = []
    dependencia: str = ""
    contacto: str = ""
    fecha_verificacion: str = ""
    preguntas: list[str] = []
    fuentes: list[Source] = []