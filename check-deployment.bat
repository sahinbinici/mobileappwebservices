@echo off
echo 🔍 Checking deployment status...

set SERVER_HOST=193.140.136.26
set SERVER_USER=cekec
set APP_NAME=mobilewebservices

echo 📊 Checking container status...
ssh %SERVER_USER%@%SERVER_HOST% "cd /home/cekec/apps/%APP_NAME% && docker-compose ps"

echo.
echo 📋 Checking recent logs...
ssh %SERVER_USER%@%SERVER_HOST% "cd /home/cekec/apps/%APP_NAME% && docker-compose logs --tail=50 app"

echo.
echo 🔌 Checking port connectivity...
ssh %SERVER_USER%@%SERVER_HOST% "netstat -tlnp | grep :8081"

echo.
echo 🏥 Testing health endpoint...
ssh %SERVER_USER%@%SERVER_HOST% "curl -s -o /dev/null -w '%%{http_code}' http://localhost:8081/mobilewebservices/actuator/health || echo 'Connection failed'"

echo.
echo 🐳 Checking Docker network...
ssh %SERVER_USER%@%SERVER_HOST% "cd /home/cekec/apps/%APP_NAME% && docker-compose exec app curl -s -o /dev/null -w '%%{http_code}' http://localhost:8082/mobilewebservices/actuator/health || echo 'Internal connection failed'"

pause