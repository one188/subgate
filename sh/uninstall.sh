
#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/subgate"
SERVICE_PATH="/etc/systemd/system/subgate.service"
PURGE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --purge)
      PURGE=1
      shift
      ;;
    *)
      echo "Unknown arg: $1"
      exit 1
      ;;
  esac
done

if systemctl list-unit-files | grep -q '^subgate.service'; then
  systemctl stop subgate.service || true
  systemctl disable subgate.service || true
fi

if [[ -f "$SERVICE_PATH" ]]; then
  rm -f "$SERVICE_PATH"
  systemctl daemon-reload
fi

if [[ "$PURGE" -eq 1 ]]; then
  rm -rf "$INSTALL_DIR"
  echo "[OK] subgate uninstalled and ${INSTALL_DIR} removed"
else
  echo "[OK] subgate service removed"
  echo "[INFO] kept data dir: ${INSTALL_DIR}"
fi
