
#!/bin/bash
set -Ee
exec > /var/log/sunshine-bootstrap.log 2>&1
echo "Bootstrap started: $(date -Is)"

wget -qO /root/setup-sunshine.sh \
  https://raw.githubusercontent.com/Wolfie432/eeStartScript/master/setup-sunshine.sh

chmod +x /root/setup-sunshine.sh
/root/setup-sunshine.sh

echo "Bootstrap finished: $(date -Is)"
