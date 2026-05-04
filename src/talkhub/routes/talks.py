from fastapi import APIRouter, HTTPException

from talkhub import store
from talkhub.models import Talk, TalkCreate

router = APIRouter(prefix="/talks", tags=["talks"])


@router.post("", response_model=Talk, status_code=201)
def submit_talk(payload: TalkCreate):
    return store.add_talk(payload)


@router.get("", response_model=list[Talk])
def list_all():
    return store.list_talks()


@router.get("/search", response_model=list[Talk])
def search(q: str):
    return store.search_talks(q)


@router.get("/{talk_id}", response_model=Talk)
def get_one(talk_id: int):
    talk = store.get_talk(talk_id)
    if talk is None:
        raise HTTPException(status_code=404, detail="talk not found")
    return talk
