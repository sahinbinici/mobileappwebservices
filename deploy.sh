#!/bin/bash

# Mobile Web Services Deployment Script
# Server: 193.140.136.26
# User: cekec

set -e

echo "🚀 Starting deployment to production server..."

# Configuration
SERVER_HOST="193.140.136.26"
SERVER_USER="cekec"
APP_NAME="mobilewebservices"
REMOTE_DIR="/home/cekec/apps/$APP_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📦 Building application locally...${NC}"
mvn clean package -DskipTests

echo -e "${YELLOW}📁 Creating deployment package...${NC}"
tar -czf ${APP_NAME}-deploy.tar.gz \
    Dockerfile \
    docker-compose.yml \
    src/ \
    pom.xml \
    .dockerignore

echo -e "${YELLOW}🚚 Uploading files to server...${NC}"
scp ${APP_NAME}-deploy.tar.gz ${SERVER_USER}@${SERVER_HOST}:/tmp/

echo -e "${YELLOW}🔧 Deploying on remote server...${NC}"
ssh ${SERVER_USER}@${SERVER_HOST} << EOF
    set -e
    
    # Create app directory if it doesn't exist
    mkdir -p $REMOTE_DIR
    cd $REMOTE_DIR
    
    # Stop existing containers if running
    if [ -f docker-compose.yml ]; then
        echo "Stopping existing containers..."
        docker-compose down || true
    fi
    
    # Extract new files
    echo "Extracting deployment package..."
    tar -xzf /tmp/${APP_NAME}-deploy.tar.gz
    
    # Build and start containers
    echo "Building and starting containers..."
    docker-compose up --build -d
    
    # Wait for services to be ready
    echo "Waiting for services to start..."
    sleep 30
    
    # Check if containers are running
    docker-compose ps
    
    # Show logs
    echo "Recent logs:"
    docker-compose logs --tail=20
    
    # Cleanup
    rm -f /tmp/${APP_NAME}-deploy.tar.gz
EOF

# Cleanup local files
rm -f ${APP_NAME}-deploy.tar.gz

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Application should be available at: http://193.140.136.26:8081/api${NC}"
echo -e "${YELLOW}📊 To check status: ssh cekec@193.140.136.26 'cd /home/cekec/apps/mobilewebservices && docker-compose ps'${NC}"
echo -e "${YELLOW}📋 To view logs: ssh cekec@193.140.136.26 'cd /home/cekec/apps/mobilewebservices && docker-compose logs -f'${NC}"