"""Lee los trámites en Markdown, los valida, genera embeddings y guarda el índice."""
import json
import sys
from datetime import datetime, timezone

from app.config import DOCS_DIR, EMBEDDING_DIM, GEMINI_EMBEDDING_MODEL, INDEX_PATH
from app.rag.embeddings import EmbeddingError, embed_texts
from app.rag.loader import build_chunks, load_all


def main() -> int:
    if not DOCS_DIR.exists():
        print(f"No existe la carpeta {DOCS_DIR}")
        return 1

    tramites, errors = load_all(DOCS_DIR)
    print(f"Archivos válidos: {len(tramites)} | con errores: {len(errors)}")

    for name, problems in errors.items():
        print(f"\n[ERROR] {name} (se omite)")
        for problem in problems:
            print("   -", problem)

    for tramite in tramites:
        for warning in tramite.warnings:
            print(f"[AVISO] {tramite.path}: {warning}")

    if not tramites:
        print("\nNo hay trámites válidos para indexar.")
        return 1

    chunks: list[dict] = []
    print("\nFragmentos por trámite:")
    for tramite in tramites:
        tramite_chunks = build_chunks(tramite)
        chunks.extend(tramite_chunks)
        print(f"  {tramite.id} {tramite.nombre}: {len(tramite_chunks)}")
    print(f"Total de fragmentos: {len(chunks)}")

    print("\nGenerando embeddings (puede tardar un poco)...")
    try:
        matrix = embed_texts([chunk["text"] for chunk in chunks])
    except EmbeddingError as e:
        print("\nERROR generando embeddings:", e.user_message)
        return 1

    for chunk, vector in zip(chunks, matrix):
        chunk["embedding"] = [round(float(x), 6) for x in vector]

    index = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "embedding_model": GEMINI_EMBEDDING_MODEL,
        "dimensions": EMBEDDING_DIM,
        "documents": [t.to_document() for t in tramites],
        "chunks": chunks,
    }

    INDEX_PATH.parent.mkdir(parents=True, exist_ok=True)
    INDEX_PATH.write_text(json.dumps(index, ensure_ascii=False), encoding="utf-8")
    size_kb = INDEX_PATH.stat().st_size / 1024
    print(f"\nÍndice guardado en {INDEX_PATH} ({size_kb:.0f} KB)")

    return 0 if not errors else 2


if __name__ == "__main__":
    sys.exit(main())