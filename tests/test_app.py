import pytest
import sys
import os

# Add the app directory to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_hello_endpoint(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Welcome to our Python Web App!" in response.data
    assert b"version" in response.data

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert b"healthy" in response.data

def test_login_endpoint(client):
    response = client.post('/login')
    assert response.status_code == 200
    assert b"login" in response.data.lower()
    assert b"demo_account" in response.data