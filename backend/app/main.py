import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import auth, cuaca, lahan, notifikasi, pemindaian, pengguna

load_dotenv()

app = FastAPI(title="Capsee Backend", version="1.0.0")

# Di production, isi CORS_ORIGINS dengan domain spesifik (dipisah koma).
_origins = os.getenv("CORS_ORIGINS", "*").strip()
allow_origins = (
    ["*"] if _origins == "*" else [origin.strip() for origin in _origins.split(",")]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(pengguna.router)
app.include_router(lahan.router)
app.include_router(pemindaian.router)
app.include_router(notifikasi.router)
app.include_router(cuaca.router)


@app.get("/")
def root():
    return {"status": "Capsee backend (Python) berjalan dengan baik"}


@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Server is healthy"}
