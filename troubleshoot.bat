@echo off
echo 🔍 Troubleshooting deployment issues...

set SERVER_HOST=193.140.136.26
set SERVER_USER=cekec

echo 📊 Checking if deployment files exist on server...
ssh %SERVER_USER%@%SERVER_HOST% "ls -la /tmp/mobilewebservices-deploy.tar.gz"

echo.
echo 📁 Checking if app directory exists...
ssh %SERVER_USER%@%SERVER_HOST% "ls -la /home/cekec/apps/ | grep mobile || echo 'Directory not found'"

echo.
echo 🐳 Checking Docker status...
ssh %SERVER_USER%@%SERVER_HOST% "docker --version && docker-compose --version"

echo.
echo 🔌 Checking if port 8081 is in use...
ssh %SERVER_USER%@%SERVER_HOST% "netstat -tlnp | grep :8081 || echo 'Port 8081 not in use'"

echo.
echo 🔥 Checking firewall status...
ssh %SERVER_USER%@%SERVER_HOST% "sudo ufw status || echo 'UFW not active'"

echo.
echo 🌐 Testing external connectivity...
curl -s -o /dev/null -w "HTTP Status: %%{http_code}" http://193.140.136.26:8081/mobilewebservices/actuator/health || echo "External connection failed"

pause