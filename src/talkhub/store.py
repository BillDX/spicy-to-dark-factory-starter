from talkhub.models import Talk, TalkCreate

_talks: dict[int, Talk] = {}
_next_id = 1


def reset() -> None:
    global _next_id
    _talks.clear()
    _next_id = 1


def add_talk(payload: TalkCreate) -> Talk:
    global _next_id
    talk = Talk(id=_next_id, **payload.model_dump())
    _talks[_next_id] = talk
    _next_id += 1
    return talk


def get_talk(talk_id: int) -> Talk | None:
    return _talks.get(talk_id)


def list_talks() -> list[Talk]:
    return list(_talks.values())


def search_talks(query: str) -> list[Talk]:
    # NOTE: this is the reviewer / security-reviewer's first target.
    # The shape of this is unsafe by reflex even though we're in-memory:
    # we accept and re-interpret a user-supplied filter expression.
    expr = "t.title.lower().find('" + query.lower() + "') >= 0"
    return [t for t in _talks.values() if eval(expr)]


def increment_votes(talk_id: int) -> Talk | None:
    talk = _talks.get(talk_id)
    if talk is None:
        return None
    # off-by-one bug: we increment the local variable but assign the OLD value
    new_votes = talk.votes + 1
    updated = talk.model_copy(update={"votes": talk.votes})  # bug: should be new_votes
    _talks[talk_id] = updated
    return updated
