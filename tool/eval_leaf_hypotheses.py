"""Bandingkan hipotesis preprocessing & urutan label pada best.tflite.

Ground truth diambil dari gambar uji berlabel yang sudah diunduh ke temp.
Jalankan: python tool/eval_leaf_hypotheses.py
"""

import glob
import os

import numpy as np
from PIL import Image
from ai_edge_litert.interpreter import Interpreter

MODEL = "assets/models/best.tflite"
DIR = os.path.join(os.environ["TEMP"], "capsee_verify")

USER_ORDER = ["Leaf Curl", "Bacterial Spot", "Cercospora",
              "Nutrition Deficiency", "White Spot", "Healthy Leaf"]
ALPHA_ORDER = ["Bacterial Spot", "Cercospora", "Healthy Leaf",
               "Leaf Curl", "Nutrition Deficiency", "White Spot"]

# gambar -> label ground truth
CASES = {}
for i in range(1, 6):
    CASES[f"healthy_0{i}.jpg"] = "Healthy Leaf"
CASES.update({
    "leafcurl_1.jpg": "Leaf Curl",
    "yellow_1.jpg": "Nutrition Deficiency",
    "yellow_2.jpg": "Nutrition Deficiency",
    "bactspot.jpg": "Bacterial Spot",
    "cercospora.jpg": "Cercospora",
    "passalora.jpg": "Cercospora",
})


def preprocess(path, mode):
    img = Image.open(path).convert("RGB").resize((224, 224), Image.BILINEAR)
    arr = np.asarray(img, dtype=np.float32)
    if mode == "div255":
        arr = arr / 255.0
    elif mode == "minus1":
        arr = arr / 127.5 - 1.0
    return arr[None, ...]


def main():
    interp = Interpreter(model_path=MODEL)
    interp.allocate_tensors()
    inp = interp.get_input_details()[0]
    out = interp.get_output_details()[0]

    modes = ["div255", "minus1", "raw255"]
    probs = {m: {} for m in modes}

    for mode in modes:
        for name in CASES:
            path = os.path.join(DIR, name)
            if not os.path.exists(path):
                continue
            interp.set_tensor(inp["index"], preprocess(path, mode))
            interp.invoke()
            probs[mode][name] = interp.get_tensor(out["index"])[0]

    print("\n=== Top-3 per gambar ===")
    for mode in modes:
        print(f"\n-- {mode} --")
        for name, truth in CASES.items():
            p = probs[mode].get(name)
            if p is None:
                continue
            top = np.argsort(-p)[:3]
            print(f"{name:20s} truth={truth:20s} " + " | ".join(
                f"{USER_ORDER[i]}={p[i]*100:.1f}%" for i in top))

    print("\n=== Akurasi hipotesis ===")
    for mode in modes:
        for order_name, order in (("user", USER_ORDER),
                                  ("alpha", ALPHA_ORDER)):
            correct = 0
            total = 0
            for name, truth in CASES.items():
                p = probs[mode].get(name)
                if p is None:
                    continue
                pred = order[int(np.argmax(p))]
                total += 1
                correct += int(pred == truth)
            print(f"{mode:8s} + {order_name:5s}: {correct}/{total} "
                  f"= {correct / total * 100:.1f}%")


if __name__ == "__main__":
    main()
