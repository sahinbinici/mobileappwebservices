@echo off
echo 🚀 Simple deployment with pre-built JAR...

set SERVER_HOST=193.140.136.26
set SERVER_USER=cekec
set APP_NAME=mobilewebservices

echo 📦 Building application locally...
call mvn clean package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo 📁 Creating simple deployment package...
copy Dockerfile.simple Dockerfile.temp
tar -czf %APP_NAME%-simple.tar.gz Dockerfile.temp docker-compose.yml target\*.war .dockerignore
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to create deployment package!
    pause
    exit /b 1
)

echo 🚚 Uploading files to server...
scp %APP_NAME%-simple.tar.gz %SERVER_USER%@%SERVER_HOST%:/tmp/
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to upload files!
    pause
    exit /b 1
)

echo 🔧 Deploying on remote server...
ssh %SERVER_USER%@%SERVER_HOST% "cd /home/cekec/apps/mobilewebservices && docker compose down 2>/dev/null || true && tar -xzf /tmp/%APP_NAME%-simple.tar.gz && mv Dockerfile.temp Dockerfile && docker compose up --build -d && sleep 30 && docker compose ps && echo 'Recent logs:' && docker compose logs --tail=20 app && rm -f /tmp/%APP_NAME%-simple.tar.gz"

if %ERRORLEVEL% neq 0 (
    echo ❌ Deployment failed!
    pause
    exit /b 1
)

echo 🧹 Cleaning up local files...
del %APP_NAME%-simple.tar.gz
del Dockerfile.temp

echo ✅ Simple deployment completed successfully!
echo 🌐 Application should be available at: http://193.140.136.26:8081/mobilewebservices

pause