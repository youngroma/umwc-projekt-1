from sklearn.linear_model import LogisticRegression

def train_model(X_train, y_train):
    """Trenuje prosty model klasyfikacji."""
    clf = LogisticRegression(max_iter=200)
    clf.fit(X_train, y_train)
    return clf