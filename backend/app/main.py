from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, lahan, pemindaian, notifikasi

app = FastAPI(title="Capsee Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # untuk production, ganti dengan domain spesifik
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(lahan.router)
app.include_router(pemindaian.router)
app.include_router(notifikasi.router)


@app.get("/")
def root():
    return {"status": "Capsee backend (Python) berjalan dengan baik"}
