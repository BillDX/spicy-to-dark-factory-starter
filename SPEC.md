# SPEC: Add a `/leaderboard` endpoint

## Summary

The talkhub service has talks and votes but no way to see which talks are winning. Add a `/leaderboard` endpoint that returns talks sorted by vote count, with pagination.

## Requirements

### Endpoint

`GET /leaderboard`

### Query parameters

- `limit` (int, default 10, max 100) — how many talks to return
- `offset` (int, default 0, min 0) — how many to skip
- `min_votes` (int, default 0) — exclude talks with fewer votes than this

### Response shape

```json
{
  "total": 42,
  "limit": 10,
  "offset": 0,
  "results": [
    {
      "rank": 1,
      "id": 17,
      "title": "Spicy Autocomplete",
      "speaker": "Bill",
      "votes": 12
    }
  ]
}
```

### Sort order

- Primary: `votes` descending
- Tiebreak: `submitted_at` ascending (earlier submissions rank higher in a tie)

### Validation

- `limit` outside `[1, 100]` → 422
- `offset < 0` → 422
- `min_votes < 0` → 422

## Acceptance criteria

- [ ] `GET /leaderboard` returns 200 with the response shape above
- [ ] Talks are sorted votes-desc, then submitted_at-asc
- [ ] `limit` and `offset` are honored
- [ ] `min_votes` filter applied before pagination
- [ ] `total` reflects the count *after* `min_votes` filtering, not the global total
- [ ] `rank` is 1-indexed and reflects the absolute position (not just within the page)
- [ ] At least three pytest tests covering: empty store, multi-page, tiebreak ordering
- [ ] `uv run pytest` green
- [ ] No new dependencies

## Out of scope

- Auth / rate limiting
- Caching
- Persistence (the store stays in-memory)
- Anti-cheat on votes (that's a different SPEC)
