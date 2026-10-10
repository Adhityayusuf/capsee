import os
from pathlib import Path
import requests
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[1] / ".env")

CLOUDINARY_CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME")
CLOUDINARY_UPLOAD_PRESET = os.getenv("CLOUDINARY_UPLOAD_PRESET")

if not CLOUDINARY_CLOUD_NAME or not CLOUDINARY_UPLOAD_PRESET:
    raise RuntimeError(
        "CLOUDINARY_CLOUD_NAME / CLOUDINARY_UPLOAD_PRESET belum diset. "
        "Lengkapi backend/.env."
    )


class CloudinaryUploadError(RuntimeError):
    """Gagal mengunggah gambar ke Cloudinary."""


def upload_ke_cloudinary(gambar_bytes: bytes, nama_file: str = "scan.jpg") -> str:
    """
    Upload gambar (dalam bentuk bytes, hasil kompresi) ke Cloudinary.
    Mengembalikan secure_url untuk disimpan ke kolom image_url di Neon.
    """
    url = f"https://api.cloudinary.com/v1_1/{CLOUDINARY_CLOUD_NAME}/image/upload"

    files = {"file": (nama_file, gambar_bytes, "image/jpeg")}
    data = {"upload_preset": CLOUDINARY_UPLOAD_PRESET}

    response = requests.post(url, files=files, data=data, timeout=30)

    if response.status_code != 200:
        raise CloudinaryUploadError(f"Upload ke Cloudinary gagal: {response.text}")

    return response.json()["secure_url"]
