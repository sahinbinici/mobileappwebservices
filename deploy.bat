@echo off
echo 🚀 Starting deployment to production server...

set SERVER_HOST=193.140.136.26
set SERVER_USER=cekec
set APP_NAME=mobilewebservices
set REMOTE_DIR=/home/cekec/apps/%APP_NAME%

echo 📦 Building application locally...
call mvn clean package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    exit /b 1
)

echo 📁 Creating deployment package...
tar -czf %APP_NAME%-deploy.tar.gz Dockerfile docker-compose.yml src/ pom.xml .dockerignore
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to create deployment package!
    exit /b 1
)

echo 🚚 Uploading files to server...
scp %APP_NAME%-deploy.tar.gz %SERVER_USER%@%SERVER_HOST%:/tmp/
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to upload files!
    exit /b 1
)

echo 🔧 Deploying on remote server...
ssh %SERVER_USER%@%SERVER_HOST% "mkdir -p %REMOTE_DIR% && cd %REMOTE_DIR% && docker-compose down 2>/dev/null || true && tar -xzf /tmp/%APP_NAME%-deploy.tar.gz && docker-compose up --build -d && sleep 30 && docker-compose ps && echo 'Recent logs:' && docker-compose logs --tail=20 && rm -f /tmp/%APP_NAME%-deploy.tar.gz"

if %ERRORLEVEL% neq 0 (
    echo ❌ Deployment failed!
    exit /b 1
)

echo 🧹 Cleaning up local files...
del %APP_NAME%-deploy.tar.gz

echo ✅ Deployment completed successfully!
echo 🌐 Application should be available at: http://193.140.136.26:8081/mobilewebservices
echo 📊 To check status: ssh cekec@193.140.136.26 "cd /home/cekec/apps/mobilewebservices && docker-compose ps"
echo 📋 To view logs: ssh cekec@193.140.136.26 "cd /home/cekec/apps/mobilewebservices && docker-compose logs -f"

pause