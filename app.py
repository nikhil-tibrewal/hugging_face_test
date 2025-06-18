from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline

app = FastAPI()
classifier = pipeline("sentiment-analysis", model="distilbert-base-uncased")

class TextInput(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Hello from HuggingFace API!"}

@app.post("/predict")
def predict(input: TextInput):
    result = classifier(input.text)
    return result
