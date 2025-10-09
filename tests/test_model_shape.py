from src.data import get_data
from src.model import train_model

def test_predict_shape():
    X_train, X_test, y_train, y_test = get_data()
    model = train_model(X_train, y_train)
    preds = model.predict(X_test)
    assert preds.shape[0] == y_test.shape[0]