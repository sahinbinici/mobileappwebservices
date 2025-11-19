@echo off
echo 🚀 Manual deployment to production server...

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

echo 📁 Creating deployment package...
tar -czf %APP_NAME%-deploy.tar.gz Dockerfile docker-compose.yml src/ pom.xml .dockerignore
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to create deployment package!
    pause
    exit /b 1
)

echo 🚚 Uploading files to server...
scp %APP_NAME%-deploy.tar.gz %SERVER_USER%@%SERVER_HOST%:/tmp/
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to upload files!
    pause
    exit /b 1
)

echo 🔧 Step-by-step deployment on remote server...
echo.
echo "Please run the following commands on the server:"
echo "ssh cekec@193.140.136.26"
echo "mkdir -p /home/cekec/apps/mobilewebservices"
echo "cd /home/cekec/apps/mobilewebservices"
echo "tar -xzf /tmp/mobilewebservices-deploy.tar.gz"
echo "docker-compose down 2>/dev/null || true"
echo "docker-compose up --build -d"
echo "docker-compose ps"
echo "docker-compose logs -f"
echo.

echo 🧹 Cleaning up local files...
del %APP_NAME%-deploy.tar.gz

echo ✅ Files uploaded successfully!
echo 🌐 After manual deployment, application should be available at: http://193.140.136.26:8081/mobilewebservices

pause