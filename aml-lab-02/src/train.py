import argparse
import json
from pathlib import Path

import joblib
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data",
        type=str,
        required=True,
        help="Ścieżka do pliku CSV z danymi treningowymi",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    data_path = args.data
    print(f"Czytam dane z: {data_path}")

    df = pd.read_csv(data_path)

    X = df.drop("label", axis=1)
    y = df["label"]

    Xtr, Xte, ytr, yte = train_test_split(
        X, y, test_size=0.3, random_state=42
    )

    clf = LogisticRegression(max_iter=1000)
    clf.fit(Xtr, ytr)

    acc = accuracy_score(yte, clf.predict(Xte))
    print(f"Dokładność modelu: {acc:.4f}")

    out_dir = Path("outputs")
    out_dir.mkdir(parents=True, exist_ok=True)

    (out_dir / "metrics.json").write_text(
        json.dumps({"accuracy": acc}, indent=2)
    )
    joblib.dump(clf, out_dir / "model.joblib")

    print("✔ Model i metryki zapisane w katalogu outputs/")


if __name__ == "__main__":
    main()