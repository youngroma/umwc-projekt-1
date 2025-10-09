import os
from sklearn.linear_model import LogisticRegression

def train_model(X_train, y_train):
    """Trenuje model z konfigurowalnym max_iter."""
    max_iter = int(os.getenv("MAX_ITER", 200))
    print(f"Training LogisticRegression(max_iter={max_iter})")
    clf = LogisticRegression(max_iter=max_iter)
    clf.fit(X_train, y_train)
    return clf
