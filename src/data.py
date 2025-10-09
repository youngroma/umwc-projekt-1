from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

def get_data(test_size: float = 0.2, random_state: int = 42):
    """Ładuje zbiór Iris i dzieli dane na train/test."""
    X, y = load_iris(return_X_y=True)
    return train_test_split(X, y, test_size=test_size, random_state=random_state)