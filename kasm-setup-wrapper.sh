
#!/bin/bash
set -Ee
exec > /var/log/kasm-bootstrap.log 2>&1

echo "Kasm bootstrap started: $(date -Is)"

wget -O /root/setup-kasm.sh \
  https://raw.githubusercontent.com/Wolfie432/eeStartScript/master/setup-kasm.sh

chmod +x /root/setup-kasm.sh
bash /root/setup-kasm.sh

echo "Kasm bootstrap finished: $(date -Is)"
