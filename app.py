from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)
classifier = pipeline("sentiment-analysis", model="prajjwal1/bert-tiny")

class TextInput(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Hello from HuggingFace API!"}

@app.post("/predict")
def predict(input: TextInput):
    result = classifier(input.text)
    return result
