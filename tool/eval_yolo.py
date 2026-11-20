"""Bandingkan preprocessing YOLOv5n CAPSEE secara statistik.

Metrik: jumlah kandidat objectness tinggi, jumlah deteksi setelah NMS,
ukuran box, dan jumlah box degeneratif.
"""

import os

import numpy as np
from PIL import Image, ImageDraw
from ai_edge_litert.interpreter import Interpreter

MODEL = "assets/models/yolov5n.tflite"
DIR = os.path.join(os.environ["TEMP"], "capsee_verify")
SIZE = 320
LABELS = ["Anthracnose", "Fruit Fly", "Fruit Rot", "Healthy Fruit"]
IMAGES = ["fruit.jpg", "fruit_plant.jpg", "fruit_bird.jpg",
          "fruit_harvest.jpg", "fruit_colours.jpg", "plant.jpg"]


def letterbox(img):
    w, h = img.size
    s = min(SIZE / w, SIZE / h)
    nw, nh = int(round(w * s)), int(round(h * s))
    canvas = Image.new("RGB", (SIZE, SIZE), (114, 114, 114))
    px, py = (SIZE - nw) // 2, (SIZE - nh) // 2
    canvas.paste(img.resize((nw, nh), Image.BILINEAR), (px, py))
    return np.asarray(canvas, dtype=np.float32), s, px, py


def iou(a, b):
    x1, y1 = max(a[0], b[0]), max(a[1], b[1])
    x2, y2 = min(a[2], b[2]), min(a[3], b[3])
    inter = max(0, x2 - x1) * max(0, y2 - y1)
    ua = ((a[2] - a[0]) * (a[3] - a[1]) + (b[2] - b[0]) * (b[3] - b[1])
          - inter)
    return inter / max(ua, 1e-9)


def nms(boxes, thr=0.45):
    boxes = sorted(boxes, key=lambda b: -b[4])
    kept = []
    for b in boxes:
        if all(b[5] != k[5] or iou(b, k) <= thr for k in kept):
            kept.append(b)
    return kept


def decode(o, obj_th, conf_th):
    out = []
    for r in o:
        obj = float(r[4])
        if obj < obj_th:
            continue
        cls = r[5:]
        ci = int(np.argmax(cls))
        conf = obj * float(cls[ci])
        if conf < conf_th:
            continue
        cx, cy, w, h = (float(v) for v in r[:4])
        out.append([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2,
                    conf, ci, obj])
    return out


def main():
    it = Interpreter(model_path=MODEL)
    it.allocate_tensors()
    inp = it.get_input_details()[0]
    out = it.get_output_details()[0]

    for fname in IMAGES:
        path = os.path.join(DIR, fname)
        if not os.path.exists(path):
            continue
        img = Image.open(path).convert("RGB")
        base, s, px, py = letterbox(img)
        print(f"\n=== {fname} {img.size} ===")
        for mode in ["div255", "minus1", "raw255"]:
            arr = base if mode == "raw255" else (
                base / 255.0 if mode == "div255" else base / 127.5 - 1.0)
            it.set_tensor(inp["index"], arr[None].astype(np.float32))
            it.invoke()
            o = it.get_tensor(out["index"])[0]
            obj = o[:, 4]
            cmax = o[:, 5:].max(axis=1)
            boxes = decode(o, 0.25, 0.25)
            kept = nms(boxes)
            strong = [b for b in kept if b[4] >= 0.35]
            areas = [max(0, b[2] - b[0]) * max(0, b[3] - b[1]) for b in kept]
            degen = sum(1 for a in areas if a < 1e-4)
            print(f"  {mode:7s} obj>0.5: {int((obj > 0.5).sum()):4d} | "
                  f"objmax={obj.max():.3f} clsmax={cmax.max():.3f} | "
                  f"nms={len(kept):4d} strong={len(strong):3d} "
                  f"degen={degen:4d} medArea="
                  f"{(np.median(areas) if areas else 0):.4f}")
            for b in sorted(strong, key=lambda x: -x[4])[:4]:
                print("     %-13s conf=%.3f obj=%.2f box=(%.3f,%.3f)-"
                      "(%.3f,%.3f)" % (LABELS[b[5]], b[4], b[6],
                                       b[0], b[1], b[2], b[3]))
            if mode in ("div255", "minus1"):
                draw_img = img.copy()
                d = ImageDraw.Draw(draw_img)
                for b in kept:
                    def back(v, pad, dim):
                        return max(0, min(dim, (v * SIZE - pad) / s))
                    x1 = back(b[0], px, img.size[0])
                    y1 = back(b[1], py, img.size[1])
                    x2 = back(b[2], px, img.size[0])
                    y2 = back(b[3], py, img.size[1])
                    d.rectangle([x1, y1, x2, y2], outline="red", width=3)
                    d.text((x1 + 3, y1 + 3),
                           f"{LABELS[b[5]]} {b[4]*100:.0f}%", fill="yellow")
                p = os.path.join(DIR, "det_" + mode + "_" + fname)
                draw_img.save(p)
                print("     overlay ->", p)


if __name__ == "__main__":
    main()
