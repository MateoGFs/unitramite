import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent

# Carga backend/.env sin importar desde dónde se ejecute el servidor.
load_dotenv(BASE_DIR / ".env")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
_fallbacks = os.getenv("GEMINI_FALLBACK_MODELS") or os.getenv("GEMINI_FALLBACK_MODEL", "")
GEMINI_FALLBACK_MODELS = [m.strip() for m in _fallbacks.split(",") if m.strip()]

# Tiempo máximo total para conseguir respuesta de la IA, sumando reintentos.
GEMINI_TOTAL_BUDGET_SECONDS = float(os.getenv("GEMINI_TOTAL_BUDGET_SECONDS", "40"))
GEMINI_EMBEDDING_MODEL = os.getenv("GEMINI_EMBEDDING_MODEL", "gemini-embedding-001")
EMBEDDING_DIM = int(os.getenv("GEMINI_EMBEDDING_DIM", "768"))

# Tiempo máximo de espera por cada llamada a Gemini.
GEMINI_TIMEOUT_SECONDS = float(os.getenv("GEMINI_TIMEOUT_SECONDS", "15"))

# Base documental e índice generado.
DOCS_DIR = BASE_DIR / "data" / "docs"
STORAGE_DIR = BASE_DIR / "storage"
INDEX_PATH = STORAGE_DIR / "index.json"



# Búsqueda de trámites (calibrados con scripts/eval_retrieval.py).
MIN_SIMILARITY = float(os.getenv("RAG_MIN_SIMILARITY", "0.60"))
SCORE_MARGIN = float(os.getenv("RAG_SCORE_MARGIN", "0.05"))
MAX_DOCS = int(os.getenv("RAG_MAX_DOCS", "3"))