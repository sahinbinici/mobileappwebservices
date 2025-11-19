@echo off
echo 🚀 Quick deployment with pre-built JAR...

echo 📦 Building application locally...
call mvn clean package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo 📁 Preparing deployment files...
copy Dockerfile.simple Dockerfile.deploy

echo 🚚 Uploading JAR and Dockerfile...
scp target\mobilewebservices-0.0.1-SNAPSHOT.war cekec@193.140.136.26:/tmp/app.war
scp Dockerfile.deploy cekec@193.140.136.26:/tmp/Dockerfile.deploy
scp docker-compose.yml cekec@193.140.136.26:/tmp/docker-compose.deploy

echo ✅ Files uploaded! Now run these commands on the server:
echo.
echo ssh cekec@193.140.136.26
echo cd /home/cekec/apps/mobilewebservices
echo cp /tmp/app.war target/
echo mkdir -p target
echo cp /tmp/app.war target/
echo cp /tmp/Dockerfile.deploy Dockerfile
echo cp /tmp/docker-compose.deploy docker-compose.yml
echo docker compose down
echo docker compose up --build -d
echo docker compose ps
echo docker compose logs app
echo.

del Dockerfile.deploy

pause