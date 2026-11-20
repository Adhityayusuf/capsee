"""Verifikasi format model TFLite CAPSEE.

Dipakai sekali untuk memastikan shape/dtype tensor, preprocessing yang benar,
dan format output YOLOv5n. Bukan bagian dari aplikasi.

Contoh:
    python tool/inspect_models.py assets/models/best.tflite --image foto_daun.jpg
    python tool/inspect_models.py assets/models/yolov5n.tflite --image foto_buah.jpg
"""

import argparse
import sys

import numpy as np
from PIL import Image
from ai_edge_litert.interpreter import Interpreter


def describe(interpreter):
    inp = interpreter.get_input_details()[0]
    out = interpreter.get_output_details()[0]
    print("INPUT :", inp["name"], inp["shape"].tolist(), inp["dtype"].__name__)
    print("OUTPUT:", out["name"], out["shape"].tolist(), out["dtype"].__name__)
    if inp["quantization_parameters"]["scales"].size:
        print("Input quantization:", inp["quantization_parameters"])
    if out["quantization_parameters"]["scales"].size:
        print("Output quantization:", out["quantization_parameters"])

    print("\n-- 15 op pertama (deteksi preprocessing di dalam model) --")
    try:
        for i, op in enumerate(interpreter._get_ops_details()[:15]):
            print(i, op["op_name"], "inputs:", list(op["inputs"]),
                  "outputs:", list(op["outputs"]))
    except Exception as exc:  # pragma: no cover - tergantung versi runtime
        print("(tidak tersedia)", exc)

    print("\n-- 8 tensor pertama --")
    for detail in interpreter.get_tensor_details()[:8]:
        print(detail["index"], detail["name"], detail["shape"].tolist(),
              detail["dtype"].__name__)


def letterbox(image, size):
    w, h = image.size
    scale = min(size / w, size / h)
    new_w, new_h = int(round(w * scale)), int(round(h * scale))
    resized = image.resize((new_w, new_h), Image.BILINEAR)
    canvas = Image.new("RGB", (size, size), (114, 114, 114))
    pad_x, pad_y = (size - new_w) // 2, (size - new_h) // 2
    canvas.paste(resized, (pad_x, pad_y))
    return np.asarray(canvas, dtype=np.float32), scale, pad_x, pad_y


def prepare(image_path, size, preprocess):
    img = Image.open(image_path).convert("RGB")
    if preprocess == "letterbox":
        arr, scale, pad_x, pad_y = letterbox(img, size)
    else:
        arr = np.asarray(img.resize((size, size), Image.BILINEAR),
                         dtype=np.float32)
        scale, pad_x, pad_y = None, None, None

    if preprocess == "minus1":
        arr = arr / 127.5 - 1.0
    elif preprocess == "raw255":
        pass
    else:
        arr = arr / 255.0
    return arr[None, ...], scale, pad_x, pad_y


def run(interpreter, image_path, size, preprocess):
    interpreter.allocate_tensors()
    inp = interpreter.get_input_details()[0]
    arr, scale, pad_x, pad_y = prepare(image_path, size, preprocess)
    interpreter.set_tensor(inp["index"], arr.astype(inp["dtype"]))
    interpreter.invoke()
    out_detail = interpreter.get_output_details()[0]
    out = interpreter.get_tensor(out_detail["index"])
    return out, scale, pad_x, pad_y


def summarize_output(out):
    print("\nOUTPUT shape:", out.shape, "dtype:", out.dtype)
    flat = out.reshape(-1)
    print("min=%.6f max=%.6f mean=%.6f" % (flat.min(), flat.max(), flat.mean()))
    print("nan:", int(np.isnan(flat).sum()))

    if out.ndim == 3:  # YOLO [1, N, F]
        rows = out[0]
        print("baris:", rows.shape[0], "field:", rows.shape[1])
        print("contoh 5 baris:")
        print(np.array2string(rows[:5], precision=4, suppress_small=True))

        print("\nstatistik per kolom (min/max):")
        for c in range(rows.shape[1]):
            col = rows[:, c]
            print("  kolom %d: %.4f .. %.4f" % (c, col.min(), col.max()))

        obj = rows[:, 4]
        conf_mask = obj > 0.25
        print("\nbaris dengan kolom4 > 0.25:", int(conf_mask.sum()))
        if conf_mask.any():
            top = rows[conf_mask]
            top = top[np.argsort(-top[:, 4])][:5]
            print("top-5 berdasarkan kolom4:")
            print(np.array2string(top, precision=4, suppress_small=True))

        for c in range(min(4, rows.shape[1])):
            col = rows[:, c]
            print("  kolom %d rentang %.2f..%.2f %s" % (
                c, col.min(), col.max(),
                "(kemungkinan piksel)" if col.max() > 1.5 else "(0-1)"))

    if out.ndim == 2 and out.shape[1] <= 20:
        print("\nskor:", np.array2string(out[0], precision=6))
        print("jumlah:", float(out[0].sum()))
        print("argmax:", int(out[0].argmax()))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("model")
    parser.add_argument("--image")
    parser.add_argument("--size", type=int)
    parser.add_argument("--preprocess", default="div255",
                        choices=["div255", "minus1", "raw255", "letterbox"])
    args = parser.parse_args()

    interpreter = Interpreter(model_path=args.model)
    interpreter.allocate_tensors()
    describe(interpreter)

    if not args.image:
        return

    inp = interpreter.get_input_details()[0]
    size = args.size or int(inp["shape"][1])
    out, scale, pad_x, pad_y = run(interpreter, args.image, size,
                                   args.preprocess)
    print("\npreprocess:", args.preprocess, "scale:", scale,
          "pad:", pad_x, pad_y)
    summarize_output(out)


if __name__ == "__main__":
    sys.exit(main())
