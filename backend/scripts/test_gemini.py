"""Prueba rápida de la conexión con Gemini (generación y embeddings)."""
import os

from dotenv import load_dotenv
from google import genai

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise SystemExit("Falta GEMINI_API_KEY en backend/.env")

model = os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
embedding_model = os.getenv("GEMINI_EMBEDDING_MODEL", "gemini-embedding-001")
client = genai.Client(api_key=api_key)

print("=== 1) Modelos disponibles para tu clave ===")
try:
    for m in client.models.list():
        actions = getattr(m, "supported_actions", None) or []
        if "embedContent" in actions:
            print("  [embeddings]", m.name)
        elif "generateContent" in actions and "flash" in m.name:
            print("  [generación] ", m.name)
except Exception as e:
    print("No se pudo listar los modelos:", e)

print()
print(f"=== 2) Generación de texto con {model} ===")
try:
    response = client.models.generate_content(
        model=model,
        contents="Explica en dos frases qué es un trámite universitario.",
    )
    print(response.text)
except Exception as e:
    print("ERROR en generación:", e)

print()
print(f"=== 3) Embeddings con {embedding_model} ===")
try:
    result = client.models.embed_content(
        model=embedding_model,
        contents="requisitos para un certificado de estudios",
    )
    vector = result.embeddings[0].values
    print("Tamaño del vector:", len(vector))
    print("Primeros 5 valores:", vector[:5])
except Exception as e:
    print("ERROR en embeddings:", e)