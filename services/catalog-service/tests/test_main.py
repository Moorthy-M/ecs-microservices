from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    response = client.get("/catalog/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_catalog_items():
    response = client.get("/catalog/items")
    assert response.status_code == 200
    payload = response.json()
    assert "items" in payload
    assert len(payload["items"]) >= 8
    assert any(item["id"] == "svc-008" for item in payload["items"])
