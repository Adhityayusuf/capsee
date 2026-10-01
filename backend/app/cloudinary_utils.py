import os
import requests
from dotenv import load_dotenv

load_dotenv()

CLOUDINARY_CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME")
CLOUDINARY_UPLOAD_PRESET = os.getenv("CLOUDINARY_UPLOAD_PRESET")


def upload_ke_cloudinary(gambar_bytes: bytes, nama_file: str = "scan.jpg") -> str:
    """
    Upload gambar (dalam bentuk bytes, hasil kompresi) ke Cloudinary.
    Mengembalikan secure_url untuk disimpan ke kolom image_url di Neon.
    """
    url = f"https://api.cloudinary.com/v1_1/{CLOUDINARY_CLOUD_NAME}/image/upload"

    files = {"file": (nama_file, gambar_bytes, "image/jpeg")}
    data = {"upload_preset": CLOUDINARY_UPLOAD_PRESET}

    response = requests.post(url, files=files, data=data)

    if response.status_code != 200:
        raise Exception(f"Upload ke Cloudinary gagal: {response.text}")

    return response.json()["secure_url"]
