"""Analisis format output YOLOv5n CAPSEE.

Mencari op pertama yang memakai input, lalu membandingkan dugaan layout
output dan preprocessing, pada gambar buah cabai.
"""

import os

import numpy as np
from PIL import Image
from ai_edge_litert.interpreter import Interpreter

MODEL = "assets/models/yolov5n.tflite"
IMG = os.path.join(os.environ["TEMP"], "capsee_verify", "fruit.jpg")
SIZE = 320


def letterbox(img, size):
    w, h = img.size
    s = min(size / w, size / h)
    nw, nh = int(round(w * s)), int(round(h * s))
    canvas = Image.new("RGB", (size, size), (114, 114, 114))
    canvas.paste(img.resize((nw, nh), Image.BILINEAR),
                 ((size - nw) // 2, (size - nh) // 2))
    return np.asarray(canvas, dtype=np.float32), s


def main():
    it = Interpreter(model_path=MODEL)
    it.allocate_tensors()
    ops = it._get_ops_details()
    print("ops consuming input tensor 0:")
    for i, op in enumerate(ops):
        if 0 in list(op["inputs"]):
            print(" ", i, op["op_name"], list(op["inputs"]),
                  "->", list(op["outputs"]))
    print("first 3 ops:", [(o["op_name"], list(o["inputs"]))
                           for o in ops[:3]])

    inp = it.get_input_details()[0]
    out = it.get_output_details()[0]
    base, s = letterbox(Image.open(IMG).convert("RGB"), SIZE)

    for name, arr in [
        ("0-1", base / 255.0),
        ("-1-1", base / 127.5 - 1.0),
        ("0-255", base),
    ]:
        it.set_tensor(inp["index"], arr[None, ...].astype(np.float32))
        it.invoke()
        o = it.get_tensor(out["index"])[0]
        cls = o[:, 5:]
        obj = o[:, 4]
        top_class = cls.max(axis=1)
        print(f"\n=== {name} === obj<max {obj.max():.4f} "
              f"cls<max {top_class.max():.4f}")
        order = np.argsort(-top_class)[:5]
        for r in order:
            print("  row%4d x=%.3f y=%.3f w=%.3f h=%.3f obj=%.3f "
                  "cls=%s" % (r, o[r, 0], o[r, 1], o[r, 2], o[r, 3],
                              o[r, 4],
                              np.round(o[r, 5:], 3)))
        # dugaan confidence = max class (tanpa objectness)
        m = top_class > 0.25
        print("  rows class>0.25:", int(m.sum()))
        if m.any():
            print("  bbox range of those rows: x %.3f..%.3f y %.3f..%.3f"
                  % (o[m, 0].min(), o[m, 0].max(),
                     o[m, 1].min(), o[m, 1].max()))
        print("  corr(obj, maxcls)=%.3f" % np.corrcoef(obj, top_class)[0, 1])


if __name__ == "__main__":
    main()
