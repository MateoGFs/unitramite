from pydantic import BaseModel, Field


class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=1000)


class Source(BaseModel):
    document_name: str
    page: int | None = None
    url: str | None = None


class AskResponse(BaseModel):
    answer: str
    sources: list[Source] = []
    found: bool = True