from fastapi import FastAPI
from app.worker import add

app = FastAPI()

@app.get("/")
def root():
    return {"status": "ok"}

@app.get("/sum")
def sum_handler(a: int, b: int):
    task = add.delay(a, b)
    return {"task_id": task.id}
