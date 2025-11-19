# Production Deployment Guide

## Sunucu Bilgileri
- **Sunucu IP**: 193.140.136.26
- **Port**: 8090
- **Container Adı**: mobilewebservices-app
- **Deployment Dizini**: /opt/mobilewebservices

## Ön Gereksinimler

### Yerel Makine (Windows)
1. Docker Desktop yüklü olmalı
2. SSH client (OpenSSH veya PuTTY)
3. SCP desteği

### Sunucu (193.140.136.26)
1. Docker ve Docker Compose yüklü olmalı
2. Port 8085 açık olmalı
3. `/opt/mobilewebservices` dizini oluşturulmuş olmalı

## Deployment Adımları

### Otomatik Deployment (Önerilen)

#### Windows için:
```cmd
deploy-production.bat
```

#### Linux/Mac için:
```bash
chmod +x deploy-production.sh
./deploy-production.sh
```

### Manuel Deployment

1. **Docker Image Oluşturma**
```bash
docker build -f Dockerfile.production -t mobilewebservices:latest .
```

2. **Image'i Kaydetme**
```bash
docker save mobilewebservices:latest -o mobilewebservices-image.tar
```

3. **Deployment Paketi Oluşturma**
```bash
tar -czf mobilewebservices-deploy.tar.gz mobilewebservices-image.tar docker-compose.production.yml Dockerfile.production
```

4. **Sunucuya Yükleme**
```bash
scp mobilewebservices-deploy.tar.gz root@193.140.136.26:/opt/mobilewebservices/
```

5. **Sunucuda Deployment**
```bash
ssh root@193.140.136.26
cd /opt/mobilewebservices
tar -xzf mobilewebservices-deploy.tar.gz
docker load -i mobilewebservices-image.tar
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml up -d
```

## Erişim URL'leri

- **Ana Uygulama**: http://193.140.136.26:8090/mobilewebservices
- **Swagger UI**: http://193.140.136.26:8090/mobilewebservices/swagger-ui.html
- **Health Check**: http://193.140.136.26:8090/mobilewebservices/actuator/health
- **API Docs**: http://193.140.136.26:8090/mobilewebservices/v3/api-docs

## Container Yönetimi

### Container Durumunu Kontrol Etme
```bash
ssh root@193.140.136.26 "docker ps | grep mobilewebservices-app"
```

### Logları Görüntüleme
```bash
ssh root@193.140.136.26 "docker logs -f mobilewebservices-app"
```

### Container'ı Durdurma
```bash
ssh root@193.140.136.26 "cd /opt/mobilewebservices && docker-compose -f docker-compose.production.yml down"
```

### Container'ı Başlatma
```bash
ssh root@193.140.136.26 "cd /opt/mobilewebservices && docker-compose -f docker-compose.production.yml up -d"
```

### Container'ı Yeniden Başlatma
```bash
ssh root@193.140.136.26 "docker restart mobilewebservices-app"
```

## Veritabanı Bağlantıları

Uygulama aşağıdaki veritabanlarına bağlanır:

1. **Default DataSource** (Duyurular)
   - Host: 193.140.136.11:3306
   - Database: duyuru

2. **News DataSource** (Haberler)
   - Host: 193.140.102.118:3306
   - Database: gaunhabermerkezivt

3. **Events DataSource** (Etkinlikler)
   - Host: 193.140.136.11:3306
   - Database: duyuru

4. **Remote Config DataSource** (Yapılandırma)
   - Host: 193.140.136.26:3306
   - Database: useful_links

## Sorun Giderme

### Container Başlamıyor
```bash
# Logları kontrol edin
ssh root@193.140.136.26 "docker logs mobilewebservices-app"

# Container durumunu kontrol edin
ssh root@193.140.136.26 "docker ps -a | grep mobilewebservices"
```

### Port Çakışması
```bash
# Port 8090'ın kullanımda olup olmadığını kontrol edin
ssh root@193.140.136.26 "netstat -tulpn | grep 8090"
```

### Veritabanı Bağlantı Hatası
- Veritabanı sunucularının erişilebilir olduğundan emin olun
- Kullanıcı adı ve şifrelerin doğru olduğunu kontrol edin
- Firewall kurallarını kontrol edin

## Güvenlik Notları

1. Üretim ortamında hassas bilgiler (şifreler) environment variables olarak saklanmalı
2. HTTPS kullanımı için reverse proxy (nginx) yapılandırılmalı
3. Düzenli güvenlik güncellemeleri yapılmalı
4. Log dosyaları düzenli olarak temizlenmeli

## Yedekleme

Container logları `/app/logs` dizininde volume olarak saklanır:
```bash
ssh root@193.140.136.26 "docker volume ls | grep mobilewebservices"
```

## Güncelleme

Yeni bir versiyon deploy etmek için:
1. Kodu güncelleyin
2. `deploy-production.bat` veya `deploy-production.sh` scriptini çalıştırın
3. Script otomatik olarak eski container'ı durdurup yenisini başlatacaktır
