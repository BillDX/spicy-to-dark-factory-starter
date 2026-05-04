from fastapi import FastAPI

from talkhub.routes import talks, votes

app = FastAPI(
    title="Conference Talk Hub",
    description="Submit talks. Vote on them. Workshop starter for agentic coding demos.",
    version="0.1.0",
)

app.include_router(talks.router)
app.include_router(votes.router)


@app.get("/")
def root():
    return {"service": "talkhub", "status": "ok"}
