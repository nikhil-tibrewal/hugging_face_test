# 🚀 HuggingFace Model API with FastAPI, Docker, GCP, and Monitoring

This is a practice project to deploy a HuggingFace NLP model as a scalable API using FastAPI. The entire stack is containerized with Docker and deployed to a GCP VM with Prometheus + Grafana monitoring. I used ChatGPT as a coding assistant throughout this exercise.

---

## 🏗️ Architecture Overview

**Stack:**
- **FastAPI + Uvicorn** — Async API server
- **HuggingFace Transformers** — Sentiment classification (`prajjwal1/bert-tiny`)
- **Docker** — Containerization
- **NGINX** — Reverse proxy (optional, for production-ready routing)
- **Prometheus + Grafana** — Monitoring setup for request/latency/error metrics

**Request Flow:**
```
Browser → http://<VM-IP>:80 → NGINX (optional) → http://localhost:8000 (FastAPI running inside Docker)
```

---

## ⚙️ Features

- ✅ Public inference endpoint using HuggingFace's `pipeline`
- ✅ Dockerized setup with pre-downloaded model
- ✅ Metrics exposed via `/metrics` using `prometheus_fastapi_instrumentator`
- ✅ Grafana dashboards showing request count, latency, errors

---

## 🌐 Deployment Instructions

### 1. 🔧 Set up GCP VM

- **VM Type**: `e2-micro`  
- **OS**: Ubuntu 22.04 LTS  
- **Disk**: 20 GB  
- **Firewall**: Allow ports `80`, `8000`, `9090`, `3000`

### 2. 📦 Clone Repo & Install Docker

```bash
git clone https://github.com/nikhil-tibrewal/hugging_face_test.git
cd hugging_face_test
sudo apt update && sudo apt install docker.io docker-compose git -y
```

---

## 🐳 Docker Build & Run

### Build the app (with preloaded model):
```bash
docker build -t hf-api .
```

### Run it:
```bash
docker run -d -p 8000:80 hf-api
```

### Test the API:
```bash
curl http://localhost:8000
# {"message":"Hello from HuggingFace API!"}

curl -X POST http://localhost:8000/predict   -H "Content-Type: application/json"   -d '{"text": "I love using FastAPI!"}'
```

---

## 📊 Monitoring with Prometheus + Grafana

### 1. Use Docker Compose:
```bash
docker-compose up -d
```

### 2. Visit dashboards:
- **Grafana**: [http://<VM-IP>:3000](http://<VM-IP>:3000)
- **Prometheus**: [http://<VM-IP>:9090](http://<VM-IP>:9090)
- **Metrics Endpoint**: [http://<VM-IP>:8000/metrics](http://<VM-IP>:8000/metrics)

### Prometheus Config Snippet (`prometheus.yml`)
```yaml
scrape_configs:
  - job_name: 'hf-api'
    static_configs:
      - targets: ['hf-api:80']
```

---

## 📁 Repo Structure

```
hugging_face_test/
├── app.py                   # FastAPI app
├── Dockerfile               # App container
├── docker-compose.yml       # Compose file for monitoring stack
├── prometheus.yml           # Prometheus config
├── requirements.txt         # Python deps
└── README.md
```

---

## 📈 How Monitoring Works

1. **FastAPI** exposes Prometheus-compatible metrics at `/metrics`.
2. **Prometheus** scrapes those metrics on a schedule and stores them.
3. **Grafana** connects to Prometheus to visualize metrics.

Metrics include:
- Request count per route
- Response time
- Error codes

---

## ✅ Sample Output

```bash
curl -X POST http://localhost:8000/predict   -H "Content-Type: application/json"   -d '{"text": "I love using FastAPI!"}'

# [{"label":"LABEL_0","score":0.5340054035186768}]
```

---

## 🏁 Future Enhancements

- [ ] Add CI/CD via GitHub Actions
- [ ] Add HTTPS support using NGINX + Let's Encrypt
- [ ] Add alerting rules to Prometheus

---

## 📄 License

MIT License © Nikhil Tibrewal
