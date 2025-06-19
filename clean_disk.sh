#!/bin/bash

# Make script executable: `chmod +x clean_disk.sh`
# Run it: `cd ~ && ./clean_disk.sh`

echo "🔧 Cleaning Docker..."
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker builder prune -a -f

echo "🧹 Cleaning pip + Hugging Face cache..."
rm -rf ~/.cache/pip
rm -rf ~/.cache/huggingface

echo "🧹 Cleaning apt cache + logs..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/log/*
sudo rm -rf /tmp/*

echo "🧾 Disk usage after cleanup:"
df -h

echo "✅ Cleanup complete."
