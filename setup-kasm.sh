
#!/bin/sh
set -e

# 1. Configuration variables (Change these as needed)
NEW_USER="clouduser"
NEW_PASS="your_secure_password"

echo "==> Creating new user: $NEW_USER"
useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:$NEW_PASS" | chpasswd

echo "==> Updating system and installing Docker..."
apt update
apt install -y docker.io

echo "==> Starting KasmVNC cloud desktop container..."
docker run -d \
    --name=cloud-desktop \
    --shm-size=1g \
    -p 6901:6901 \
    -e VNC_PW=password123 \
    kasmweb/desktop:1.18.0
