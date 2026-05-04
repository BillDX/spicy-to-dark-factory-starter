from datetime import datetime, timezone

from pydantic import BaseModel, Field


class TalkCreate(BaseModel):
    title: str
    speaker: str
    abstract: str


class Talk(BaseModel):
    id: int
    title: str
    speaker: str
    abstract: str
    submitted_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    votes: int = 0


class VoteResponse(BaseModel):
    talk_id: int
    votes: int
