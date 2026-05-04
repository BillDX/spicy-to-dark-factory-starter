import pytest
from fastapi.testclient import TestClient

from talkhub import store
from talkhub.main import app


@pytest.fixture(autouse=True)
def fresh_store():
    store.reset()
    yield
    store.reset()


@pytest.fixture
def client():
    return TestClient(app)
