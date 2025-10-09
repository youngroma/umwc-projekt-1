from src.data import get_data
from src.model import train_model
from sklearn.metrics import accuracy_score

def test_accuracy_minimum():
    X_train, X_test, y_train, y_test = get_data()
    model = train_model(X_train, y_train)
    acc = accuracy_score(y_test, model.predict(X_test))
    assert acc >= 0.7, f"Oczekiwane minimum accuracy 0.7, uzyskano {acc:.3f}"