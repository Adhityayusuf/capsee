from fastapi import HTTPException
from psycopg2.extensions import cursor as PgCursor


def pastikan_lahan_milik_pengguna(
    cur: PgCursor, id_lahan: str, id_pengguna: str
) -> None:
    """Pastikan lahan ada DAN dimiliki pengguna yang sedang login.

    Dipakai sebelum membaca/menulis data turunan lahan (jadwal, riwayat,
    pemindaian) agar pengguna tidak bisa mengintip lahan milik orang lain.
    """
    cur.execute(
        "SELECT 1 FROM lahan WHERE id = %s AND id_pengguna = %s",
        (id_lahan, id_pengguna),
    )
    if cur.fetchone() is None:
        raise HTTPException(status_code=404, detail="Lahan tidak ditemukan")
