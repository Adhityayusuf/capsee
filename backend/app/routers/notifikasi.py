from fastapi import APIRouter, Depends, HTTPException
from app.database import get_db_connection
from app.security import verifikasi_token

router = APIRouter(prefix="/api/notifikasi", tags=["Notifikasi"])


@router.get("")
def daftar_notifikasi(id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT * FROM notifikasi WHERE id_pengguna = %s ORDER BY dibuat_pada DESC",
            (id_pengguna,),
        )
        kolom = [desc[0] for desc in cur.description]
        hasil = [dict(zip(kolom, row)) for row in cur.fetchall()]
        return {"notifikasi": hasil}


@router.patch("/{id_notifikasi}/baca")
def tandai_dibaca(id_notifikasi: str, id_pengguna: str = Depends(verifikasi_token)):
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            UPDATE notifikasi SET sudah_dibaca = true
            WHERE id = %s AND id_pengguna = %s
            RETURNING *
            """,
            (id_notifikasi, id_pengguna),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Notifikasi tidak ditemukan")
        kolom = [desc[0] for desc in cur.description]
        return {"notifikasi": dict(zip(kolom, row))}
