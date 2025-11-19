# Mobile Web Services - Docker Deployment Guide

## Sunucu Bilgileri
- **Sunucu IP:** 193.140.136.26
- **Kullanıcı:** cekec
- **Şifre:** sahinbey_

## Deployment Adımları

### 1. Projeyi Sunucuya Yükleme

```bash
# Projeyi tar dosyası olarak paketleyin (Windows'ta)
tar -czf mobilewebservices-deploy.tar.gz Dockerfile docker-compose.yml src/ pom.xml .dockerignore

# Dosyayı sunucuya yükleyin
scp mobilewebservices-deploy.tar.gz cekec@193.140.136.26:/tmp/
```

### 2. Sunucuda Deployment

```bash
# Sunucuya bağlanın
ssh cekec@193.140.136.26

# Uygulama dizinini oluşturun
mkdir -p /home/cekec/apps/mobilewebservices
cd /home/cekec/apps/mobilewebservices

# Mevcut container'ları durdurun (varsa)
docker-compose down

# Yeni dosyaları çıkarın
tar -xzf /tmp/mobilewebservices-deploy.tar.gz

# Container'ları build edin ve başlatın
docker-compose up --build -d

# Durumu kontrol edin
docker-compose ps
docker-compose logs -f
```

### 3. Uygulama Erişimi

- **URL:** http://193.140.136.26:8081/mobilewebservices
- **Health Check:** http://193.140.136.26:8081/mobilewebservices/actuator/health
- **MySQL Port:** 3307 (dış erişim için)

### 4. Yararlı Komutlar

```bash
# Container durumunu kontrol etme
docker-compose ps

# Logları görüntüleme
docker-compose logs -f

# Container'ları yeniden başlatma
docker-compose restart

# Container'ları durdurma
docker-compose down

# Veritabanına bağlanma
docker exec -it mobilewebservices-mysql mysql -u mobileapp -p mobilewebservices
```

### 5. Güvenlik Notları

- MySQL root şifresi: `sahinbey123`
- Uygulama veritabanı kullanıcısı: `mobileapp` / `mobileapp123`
- Port 8081 üzerinden erişim sağlanır
- Sadece gerekli portlar expose edilir

### 6. Sorun Giderme

```bash
# Container loglarını kontrol etme
docker-compose logs app
docker-compose logs mysql

# Container içine girme
docker exec -it mobilewebservices-app bash
docker exec -it mobilewebservices-mysql bash

# Veritabanı bağlantısını test etme
docker exec -it mobilewebservices-mysql mysql -u root -p -e "SHOW DATABASES;"
```