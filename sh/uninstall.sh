#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/subgate"
SERVICE_PATH="/etc/systemd/system/subgate.service"

if systemctl list-unit-files | grep -q '^subgate.service'; then
  systemctl stop subgate.service || true
  systemctl disable subgate.service || true
fi

if [[ -f "$SERVICE_PATH" ]]; then
  rm -f "$SERVICE_PATH"
  systemctl daemon-reload
fi

rm -rf "$INSTALL_DIR"
echo "[OK] subgate uninstalled"
echo "[INFO] removed: ${INSTALL_DIR}"
