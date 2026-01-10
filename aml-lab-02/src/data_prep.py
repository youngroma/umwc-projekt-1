from pathlib import Path

import pandas as pd
from sklearn.datasets import make_classification


def main():
    print("Generuję dataset…")
    X, y = make_classification(
        n_samples=500,
        n_features=10,
        n_informative=4,
        random_state=24,
    )

    df = pd.DataFrame(X, columns=[f"f{i}" for i in range(10)])
    df["label"] = y

    out_dir = Path("outputs")
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "data.csv"

    df.to_csv(out_path, index=False)
    print(f"✔ Dataset zapisany: {out_path}")


if __name__ == "__main__":
    main()