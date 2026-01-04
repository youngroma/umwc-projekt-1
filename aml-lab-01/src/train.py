import json
from pathlib import Path
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib

def main():
    X, y = make_classification(n_samples=1000, n_features=20, n_informative=6, random_state=42)
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.25, random_state=42)

    clf = LogisticRegression(max_iter=1000)
    clf.fit(Xtr, ytr)
    acc = accuracy_score(yte, clf.predict(Xte))

    out = Path("outputs")
    out.mkdir(exist_ok=True)
    (out / "metrics.json").write_text(json.dumps({"accuracy": acc}, indent=2))
    joblib.dump(clf, out / "model.joblib")
    print(f"Model zapisany. Dokładność: {acc:.4f}")

if __name__ == "__main__":
    main()
