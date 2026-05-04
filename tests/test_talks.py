def test_submit_and_list(client):
    payload = {"title": "Spicy Autocomplete", "speaker": "Bill", "abstract": "Yum."}
    r = client.post("/talks", json=payload)
    assert r.status_code == 201
    talk = r.json()
    assert talk["id"] == 1
    assert talk["votes"] == 0

    r = client.get("/talks")
    assert r.status_code == 200
    assert len(r.json()) == 1


def test_get_missing(client):
    r = client.get("/talks/999")
    assert r.status_code == 404
