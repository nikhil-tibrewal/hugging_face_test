# Architecture:
- FastAPI + Uvicorn server for async handling
- Hugging-face API to do basic sentiment analysis
- Docker for containerization
- Nginx for reverse proxy
	- Before Nginx: Browser → http://<VM-IP>:8000 → FastAPI running via Docker
	- After Nginx: Browser → http://<VM-IP>:80 → NGINX → http://localhost:8000 (FastAPI in Docker)
	- Or if using SSL: Browser → https://yourdomain.com → NGINX (SSL) → FastAPI
	- NGINX will listen on port 80 (public) and proxy to localhost:8000 (our FastAPI app via Docker).
- Monitoring with Prometheus + Grafana:
	- Prometheus: to scrape metrics
	- Grafana: to visualize them
	- Instrumentator: to expose FastAPI metrics
	- All running on the GCP VM (in Docker).
- The system uses Prometheus and Grafana to monitor a FastAPI-based HuggingFace model API:
    - FastAPI Metrics Exposure. The FastAPI application exposes metrics at the /metrics endpoint using the prometheus_fastapi_instrumentator library. These metrics include request counts, response times, status codes, and path patterns.
    - Prometheus Metrics Collection: Prometheus is configured to periodically scrape the FastAPI metrics endpoint. It stores the collected time-series data in its internal database for querying and analysis.
    - Grafana Visualization: Grafana is used to visualize the metrics stored in Prometheus. It connects to Prometheus as a data source and provides dashboards for monitoring application performance, error rates, and latency trends in real time.
	- Together, this setup enables scalable, real-time observability of the model inference API.

# Deployment:
1. Set up a VM instance on GCP: e2-micro
    - Name: huggingface-api
    - Region/Zone: Choose close to your users
    - Machine type: e2-micro or better
    - Boot disk:
        - OS: Ubuntu 22.04 LTS
        - Size: 20 GB
    - Firewall:
        - Allow HTTP traffic
        - Allow HTTPS traffic
2. To run the server on the VM:
	- SSH into the VM
	- Clone the git repo: <TODO>
	- Build the docker image: `docker build -t hf-api .`
	- Run the docker image: `docker run -d -p 8000:80 hf-api`
	- Call the API: `curl http://localhost:8000` to test the home endpoint
	- Call the predict endpoint to test using the model:
		```$ curl -X POST http://localhost:8000/predict \
		  -H "Content-Type: application/json" \
		  -d '{"text": "I love using FastAPI!"}'
		$ [{"label":"LABEL_0","score":0.5340054035186768}]```
3. Helpful docker commands:
	- `docker ps -a`
	- `docker container prune -f`: cleans up all images
	- `docker logs <container_id>`
	- `docker stop <container_id>`
4. To setup Nginx reverse proxy:
	- `sudo apt update`
	- `sudo apt install nginx -y`
	- `sudo vi /etc/nginx/sites-available/default`
		- Replace with the following:
		```server {
		    listen 80;
		    server_name _;

		    location / {
		        proxy_pass http://localhost:8000;
		        proxy_set_header Host $host;
		        proxy_set_header X-Real-IP $remote_addr;
		        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		    }
		}```
	- `sudo nginx -t && sudo systemctl restart nginx`
	- Go to http://<gcp_vm_external_ip> and that should load as expected
5. http://<external_id>/metrics should show Prometheus-compatible metrics
6. To set up prometheus and grafana:
	- `$ docker-compose up --build -d`. This command:
		- Builds your app image (hf-api)
		- Starts containers for:
			- FastAPI app
			- Prometheus
			- Grafana
		- Hooks them into a shared network
		- http://localhost:8000 → FastAPI
		- http://localhost:8000/metrics → Prometheus metrics
		- http://localhost:9090 → Prometheus UI
		- http://localhost:3000 → Grafana dashboard
	- `$ docker-compose down`. This:
    	- Stops and removes all containers from the docker-compose.yml
    	- Removes default network
    	- Keeps your images and volumes
7. To access endpoints from browser, we need to create a firewall rule to allow TCP ingres to the relevant ports:
	- Go to your GCP Console
	- Navigate to: VPC Network > Firewall
	- Click “Create firewall rule”
	- Set:
    	- Name: allow-monitoring
    	- Targets: All instances in the network (or specify your VM’s tag)
    	- Source IP ranges: 0.0.0.0/0
    	- Protocols and ports:
			- Select “Specified protocols and ports”
    		- Check “tcp”
			- Add: 8000,9090,3000
	- Now all 3 endpoints should work:
		- http://<external_ip>:8000 → FastAPI
		- http://<external_ip>:8000/metrics → Prometheus metrics
		- http://<external_ip>:9090 → Prometheus UI
		- http://<external_ip>:3000 → Grafana dashboard