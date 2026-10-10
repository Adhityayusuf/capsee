import io
from PIL import Image


def kompres_gambar(
    file_bytes: bytes,
    kualitas: int = 70,
    lebar_maksimal: int = 1280,
) -> bytes:
    """
    Mengompres gambar hasil scan sebelum diupload ke Cloudinary.

    - kualitas: 1-100, makin kecil makin kompres (70 sudah cukup bagus
      untuk analisis ML, tapi ukuran file jauh lebih kecil dari foto asli)
    - lebar_maksimal: foto di-resize kalau lebih lebar dari ini, tinggi
      menyesuaikan proporsional (tidak gepeng)
    """
    gambar = Image.open(io.BytesIO(file_bytes))

    # Konversi ke RGB dulu (perlu kalau foto formatnya PNG dengan transparansi,
    # karena JPEG tidak mendukung channel alpha)
    if gambar.mode in ("RGBA", "P"):
        gambar = gambar.convert("RGB")

    # Resize kalau gambar terlalu besar (foto HP modern bisa 4000px+ lebar)
    if gambar.width > lebar_maksimal:
        rasio = lebar_maksimal / gambar.width
        tinggi_baru = int(gambar.height * rasio)
        gambar = gambar.resize((lebar_maksimal, tinggi_baru), Image.LANCZOS)

    # Simpan sebagai JPEG terkompresi ke memory (bukan ke disk)
    buffer = io.BytesIO()
    gambar.save(buffer, format="JPEG", quality=kualitas, optimize=True)
    
    hasil_kompresi = buffer.getvalue()
    
    # Jangan gunakan hasil kompresi jika ukurannya malah lebih besar dari aslinya
    if len(hasil_kompresi) > len(file_bytes):
        return file_bytes
        
    return hasil_kompresi
