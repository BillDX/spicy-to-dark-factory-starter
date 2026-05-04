from fastapi import APIRouter, HTTPException

from talkhub import store
from talkhub.models import VoteResponse

router = APIRouter(tags=["votes"])


@router.post("/talks/{talk_id}/votes", response_model=VoteResponse)
def cast_vote(talk_id: int):
    talk = store.increment_votes(talk_id)
    if talk is None:
        raise HTTPException(status_code=404, detail="talk not found")
    return VoteResponse(talk_id=talk.id, votes=talk.votes)
