#!/bin/bash

echo "🚀 Setting up Mobile Web Services on server..."

# Create directories
echo "📁 Creating directories..."
mkdir -p /home/cekec/apps/mobilewebservices
cd /home/cekec/apps/mobilewebservices

# Check if deployment file exists
if [ ! -f "/tmp/mobilewebservices-deploy.tar.gz" ]; then
    echo "❌ Deployment file not found at /tmp/mobilewebservices-deploy.tar.gz"
    echo "Please upload the file first using: scp mobilewebservices-deploy.tar.gz cekec@193.140.136.26:/tmp/"
    exit 1
fi

# Extract deployment files
echo "📦 Extracting deployment files..."
tar -xzf /tmp/mobilewebservices-deploy.tar.gz

# Check if Docker Compose is available
echo "🐳 Checking Docker Compose..."
if command -v "docker compose" &> /dev/null; then
    echo "✅ Docker Compose V2 found"
    DOCKER_COMPOSE="docker compose"
elif command -v "docker-compose" &> /dev/null; then
    echo "✅ Docker Compose V1 found"
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Docker Compose not found. Installing..."
    
    # Install Docker Compose V2 (plugin)
    sudo apt update
    sudo apt install -y docker-compose-plugin
    
    if command -v "docker compose" &> /dev/null; then
        echo "✅ Docker Compose V2 installed successfully"
        DOCKER_COMPOSE="docker compose"
    else
        echo "❌ Failed to install Docker Compose V2, trying standalone version..."
        
        # Install standalone Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        if command -v "docker-compose" &> /dev/null; then
            echo "✅ Docker Compose standalone installed successfully"
            DOCKER_COMPOSE="docker-compose"
        else
            echo "❌ Failed to install Docker Compose"
            exit 1
        fi
    fi
fi

# Stop existing containers if any
echo "🛑 Stopping existing containers..."
$DOCKER_COMPOSE down 2>/dev/null || true

# Build and start containers
echo "🔨 Building and starting containers..."
$DOCKER_COMPOSE up --build -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check container status
echo "📊 Container status:"
$DOCKER_COMPOSE ps

# Check logs
echo "📋 Recent logs:"
$DOCKER_COMPOSE logs --tail=20 app

# Test health endpoint
echo "🏥 Testing health endpoint..."
sleep 10
curl -s http://localhost:8081/mobilewebservices/actuator/health || echo "Health check failed"

# Check port
echo "🔌 Checking port 8081..."
netstat -tlnp | grep :8081 || echo "Port 8081 not listening"

echo "✅ Deployment completed!"
echo "🌐 Application should be available at: http://193.140.136.26:8081/mobilewebservices"

# Cleanup
rm -f /tmp/mobilewebservices-deploy.tar.gz