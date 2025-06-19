# Start with slim Python base
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy FastAPI app code
COPY . .

# Start the app on port 80
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80", "--loop", "asyncio"]
