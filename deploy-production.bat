@echo off
REM Production Deployment Script for Windows
REM Target Server: 193.140.136.26
REM Port: 8090

echo ==========================================
echo Mobile Web Services - Production Deployment
echo Target Server: 193.140.136.26
echo Port: 8090
echo ==========================================
echo.

REM Configuration
set SERVER_IP=193.140.136.26
set SERVER_USER=root
set REMOTE_DIR=/opt/mobilewebservices
set CONTAINER_NAME=mobilewebservices-app
set IMAGE_NAME=mobilewebservices

echo Step 1: Building Docker image locally...
docker build -f Dockerfile.production -t %IMAGE_NAME%:latest .
if errorlevel 1 (
    echo ERROR: Docker build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Saving Docker image to tar file...
docker save %IMAGE_NAME%:latest -o mobilewebservices-image.tar
if errorlevel 1 (
    echo ERROR: Docker save failed!
    pause
    exit /b 1
)

echo.
echo Step 3: Creating deployment package...
tar -czf mobilewebservices-deploy.tar.gz mobilewebservices-image.tar docker-compose.production.yml Dockerfile.production
if errorlevel 1 (
    echo ERROR: Creating deployment package failed!
    pause
    exit /b 1
)

echo.
echo Step 4: Uploading to server...
scp mobilewebservices-deploy.tar.gz %SERVER_USER%@%SERVER_IP%:%REMOTE_DIR%/
if errorlevel 1 (
    echo ERROR: Upload failed!
    pause
    exit /b 1
)

echo.
echo Step 5: Deploying on server...
ssh %SERVER_USER%@%SERVER_IP% "cd %REMOTE_DIR% && tar -xzf mobilewebservices-deploy.tar.gz && docker load -i mobilewebservices-image.tar && docker-compose -f docker-compose.production.yml down && docker-compose -f docker-compose.production.yml up -d && rm -f mobilewebservices-image.tar mobilewebservices-deploy.tar.gz && sleep 10 && docker ps | grep %CONTAINER_NAME%"
if errorlevel 1 (
    echo ERROR: Deployment failed!
    pause
    exit /b 1
)

echo.
echo Step 6: Cleaning up local files...
del mobilewebservices-image.tar
del mobilewebservices-deploy.tar.gz

echo.
echo ==========================================
echo Deployment completed successfully!
echo ==========================================
echo.
echo Application is now running at:
echo   - Main URL: http://%SERVER_IP%:8090/mobilewebservices
echo   - Swagger: http://%SERVER_IP%:8090/mobilewebservices/swagger-ui.html
echo   - Health: http://%SERVER_IP%:8090/mobilewebservices/actuator/health
echo.
echo To view logs:
echo   ssh %SERVER_USER%@%SERVER_IP% "docker logs -f %CONTAINER_NAME%"
echo.
pause
