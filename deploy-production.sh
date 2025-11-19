#!/bin/bash

# Production Deployment Script for 193.140.136.26
# Port: 8090

set -e

echo "=========================================="
echo "Mobile Web Services - Production Deployment"
echo "Target Server: 193.140.136.26"
echo "Port: 8090"
echo "=========================================="

# Configuration
SERVER_IP="193.140.136.26"
SERVER_USER="root"
REMOTE_DIR="/opt/mobilewebservices"
CONTAINER_NAME="mobilewebservices-app"
IMAGE_NAME="mobilewebservices"

echo ""
echo "Step 1: Building Docker image locally..."
docker build -f Dockerfile.production -t ${IMAGE_NAME}:latest .

echo ""
echo "Step 2: Saving Docker image to tar file..."
docker save ${IMAGE_NAME}:latest -o mobilewebservices-image.tar

echo ""
echo "Step 3: Creating deployment package..."
tar -czf mobilewebservices-deploy.tar.gz \
    mobilewebservices-image.tar \
    docker-compose.production.yml \
    Dockerfile.production

echo ""
echo "Step 4: Uploading to server..."
scp mobilewebservices-deploy.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/

echo ""
echo "Step 5: Deploying on server..."
ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd /opt/mobilewebservices

echo "Extracting deployment package..."
tar -xzf mobilewebservices-deploy.tar.gz

echo "Loading Docker image..."
docker load -i mobilewebservices-image.tar

echo "Stopping existing container (if any)..."
docker-compose -f docker-compose.production.yml down || true

echo "Starting new container..."
docker-compose -f docker-compose.production.yml up -d

echo "Cleaning up..."
rm -f mobilewebservices-image.tar mobilewebservices-deploy.tar.gz

echo "Waiting for application to start..."
sleep 10

echo "Checking container status..."
docker ps | grep mobilewebservices-app

echo ""
echo "Deployment completed!"
echo "Application URL: http://193.140.136.26:8090/mobilewebservices"
echo "Swagger UI: http://193.140.136.26:8090/mobilewebservices/swagger-ui.html"
echo "Health Check: http://193.140.136.26:8090/mobilewebservices/actuator/health"
ENDSSH

echo ""
echo "Step 6: Cleaning up local files..."
rm -f mobilewebservices-image.tar mobilewebservices-deploy.tar.gz

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Application is now running at:"
echo "  - Main URL: http://193.140.136.26:8090/mobilewebservices"
echo "  - Swagger: http://193.140.136.26:8090/mobilewebservices/swagger-ui.html"
echo "  - Health: http://193.140.136.26:8090/mobilewebservices/actuator/health"
echo ""
echo "To view logs:"
echo "  ssh ${SERVER_USER}@${SERVER_IP} 'docker logs -f ${CONTAINER_NAME}'"
echo ""
