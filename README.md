# Subgate 1.1.1 在线授权部署文档

本文适用于 Linux 服务器，目标是快速部署 `subgate` 客户端并接入你的授权站。

## 一键命令（推荐）

安装（默认安装到 `/opt/subgate`）：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/one188/subgate/sh/install.sh)
```

升级（默认升级到最新 release）：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/one188/subgate/sh/upgrade.sh)
```

升级到指定版本（示例 `v1.1.1`）：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/one188/subgate/sh/upgrade.sh) --version v1.1.1
```

卸载（保留 `/opt/subgate` 配置和日志）：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/one188/subgate/main/sh/uninstall.sh)
```

卸载并删除 `/opt/subgate` 全部文件：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/one188/subgate/main/sh/uninstall.sh) --purge
```

## 手动安装

创建目录：
```bash
mkdir -p /opt/subgate
```

下载可执行文件到 `/opt/subgate/subgate`（也可以手动上传）：
```bash
curl -fL "https://github.com/one188/subgate/releases/download/v1.1.1/subgate" -o /opt/subgate/subgate
chmod 755 /opt/subgate/subgate
```

## 配置文件说明

示例配置请参考：
[config.json](https://github.com/one188/subgate/blob/main/config.json)

客户端默认读取：
- `/opt/subgate/config.json`
- `/opt/subgate/whitelist.txt`

`config.json` 关键字段：
- `run_mode`: 运行模式（1~4）
- 模式1 全量上传服务端判断
- 模式2 下载规则列表和IP列表本地判断+全量上传日志到服务器
- 模式3 下载规则列表和IP列表本地判断+只上传命中的规则到服务器
- 模式4 下载规则列表和IP列表本地判断+不上传任何数据
- `protocol`: `http` 或 `grpc`（grpc 当前为 WebSocket 长连接模式）
- `tg_bot_token`: Telegram Bot Token
- `tg_chat_id`: Telegram Chat ID
- `timeout_default_allow`: 服务端请求超时时是否默认放行

`whitelist.txt`：每行一个邮箱，支持 `#` 注释。

## 获取机器码并开通授权

先获取机器码：
```bash
cd /opt/subgate
./subgate -auth
```

将机器码提交到授权站完成 key 注册/续费后，启动程序：
```bash
cd /opt/subgate
./subgate
```

## systemd 保活

安装脚本会自动创建服务。若你手动配置，可使用：
```bash
cat >/etc/systemd/system/subgate.service <<'UNIT'
[Unit]
Description=subgate Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/subgate
ExecStart=/opt/subgate/subgate
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now subgate.service
systemctl status subgate.service --no-pager
```

常用命令：
```bash
systemctl restart subgate
systemctl stop subgate
systemctl start subgate
journalctl -u subgate -f
```

## v2board / xboard 接入

替换前先备份原文件。

v2board 常见路径：
- `/www/wwwroot/站点名/app/Http/Controllers/Client/ClientController.php`

xboard 常见路径：
- `/www/wwwroot/站点名/app/Http/Controllers/V1/Client/ClientController.php`

将仓库中的 `v2board.php` / `xboard.php` 适配后替换对应控制器代码。

## Nginx 访客 IP 校验

确保站点日志能看到真实访客 IP：
```bash
ls /www/wwwlogs/
tail -f /www/wwwlogs/你的站点.log
```

能持续刷出正常公网 IP 即代表 Nginx 取 IP 正常。

## 脚本路径

- 安装脚本：`/sh/install.sh`
- 升级脚本：`/sh/upgrade.sh`
- 卸载脚本：`/sh/uninstall.sh`

