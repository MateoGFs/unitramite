"""Prueba qué modelos de generación puede usar tu clave y cuánto tardan."""
import os
import time

from dotenv import load_dotenv
from google import genai

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise SystemExit("Falta GEMINI_API_KEY en backend/.env")

client = genai.Client(api_key=api_key)

CANDIDATES = [
    "gemini-3.8-flash",
    "gemini-3.7-flash",
    "gemini-3.5-flash",
    "gemini-3.5-flash-lite",
    "gemini-3.1-flash-lite",
    "gemini-flash-latest",
    "gemini-flash-lite-latest",
]

for name in CANDIDATES:
    start = time.time()
    try:
        response = client.models.generate_content(
            model=name,
            contents="Responde solo con la palabra: listo",
        )
        seconds = time.time() - start
        text = (response.text or "").strip()[:40]
        print(f"OK     {name:28} {seconds:4.1f}s  -> {text}")
    except Exception as e:
        print(f"FALLA  {name:28} {str(e)[:120]}")
    time.sleep(2)  # pausa corta para no chocar con límites por minuto