#!/bin/bash

echo "🚀 Running Mobile Web Services without Docker..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Installing OpenJDK 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
fi

# Check Java version
java -version

# Create app directory
mkdir -p /home/cekec/apps/mobilewebservices
cd /home/cekec/apps/mobilewebservices

# Copy JAR file
if [ -f "/tmp/app.war" ]; then
    cp /tmp/app.war ./mobilewebservices.war
else
    echo "❌ JAR file not found at /tmp/app.war"
    exit 1
fi

# Set environment variables for Docker profile
export SPRING_PROFILES_ACTIVE=docker
export SPRING_DATASOURCE_DEFAULT_JDBC_URL=jdbc:mysql://localhost:3306/mobilewebservices
export SPRING_DATASOURCE_DEFAULT_USERNAME=mobileapp
export SPRING_DATASOURCE_DEFAULT_PASSWORD=mobileapp123
export SPRING_DATASOURCE_REMOTECONFIG_JDBC_URL=jdbc:mysql://localhost:3306/mobilewebservices
export SPRING_DATASOURCE_REMOTECONFIG_USERNAME=mobileapp
export SPRING_DATASOURCE_REMOTECONFIG_PASSWORD=mobileapp123
export SERVER_PORT=8082

# Kill existing process if running
pkill -f mobilewebservices.war || true

# Start MySQL container only
docker run -d \
  --name mobilewebservices-mysql \
  -e MYSQL_ROOT_PASSWORD=sahinbey123 \
  -e MYSQL_DATABASE=mobilewebservices \
  -e MYSQL_USER=mobileapp \
  -e MYSQL_PASSWORD=mobileapp123 \
  -p 3306:3306 \
  mysql:8.0 \
  --default-authentication-plugin=mysql_native_password

# Wait for MySQL to start
echo "⏳ Waiting for MySQL to start..."
sleep 30

# Run the application
echo "🚀 Starting Mobile Web Services..."
nohup java -jar mobilewebservices.war > app.log 2>&1 &

# Get the process ID
APP_PID=$!
echo "📊 Application started with PID: $APP_PID"

# Wait a bit and check if it's running
sleep 10
if ps -p $APP_PID > /dev/null; then
    echo "✅ Application is running!"
    echo "🌐 Application should be available at: http://193.140.136.26:8082/mobilewebservices"
    echo "📋 To view logs: tail -f /home/cekec/apps/mobilewebservices/app.log"
    echo "🛑 To stop: kill $APP_PID"
else
    echo "❌ Application failed to start. Check logs:"
    cat app.log
fi