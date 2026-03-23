
#!/usr/bin/env bash
set -euo pipefail

REPO="one188/subgate"
INSTALL_DIR="/opt/subgate"
BIN_PATH="$INSTALL_DIR/subgate"
SERVICE_PATH="/etc/systemd/system/subgate.service"
VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
fi

if [[ -z "$VERSION" ]]; then
  echo "[ERR] Failed to resolve release version"
  exit 1
fi

mkdir -p "$INSTALL_DIR"

ASSET_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
  | grep -Eo '"browser_download_url":[[:space:]]*"[^"]+"' \
  | cut -d'"' -f4 \
  | grep -E '/subgate$|linux.*amd64|amd64.*subgate' \
  | head -n1 || true)

if [[ -z "$ASSET_URL" ]]; then
  ASSET_URL="https://github.com/${REPO}/releases/download/${VERSION}/subgate"
fi

echo "[INFO] Installing ${VERSION} from: ${ASSET_URL}"
curl -fL "$ASSET_URL" -o "$BIN_PATH"
chmod 755 "$BIN_PATH"

if [[ ! -f "$INSTALL_DIR/config.json" ]]; then
  cat >"$INSTALL_DIR/config.json" <<'JSON'
{
  "run_mode": 1,
  "protocol": "http",
  "tg_bot_token": "",
  "tg_chat_id": "",
  "timeout_default_allow": false
}
JSON
  echo "[INFO] Created $INSTALL_DIR/config.json"
fi

if [[ ! -f "$INSTALL_DIR/whitelist.txt" ]]; then
  : > "$INSTALL_DIR/whitelist.txt"
  echo "[INFO] Created $INSTALL_DIR/whitelist.txt"
fi

cat >"$SERVICE_PATH" <<UNIT
[Unit]
Description=subgate Service
After=network.target

[Service]
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=${BIN_PATH}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now subgate.service

echo "[OK] subgate installed"
echo "[INFO] Machine ID command: ${BIN_PATH} -auth"
echo "[INFO] Service status: systemctl status subgate --no-pager"
