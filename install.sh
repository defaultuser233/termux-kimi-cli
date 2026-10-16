#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

KIMI_BIN="$HOME/.kimi-code/bin/kimi"
RUNNER="$(command -v glibc-runner || true)"

echo "[*] 检查依赖..."
if ! command -v glibc-runner >/dev/null 2>&1; then
  echo "[*] 安装 glibc-repo / glibc-runner"
  pkg install -y glibc-repo
  pkg install -y glibc-runner
  RUNNER="$(command -v glibc-runner)"
fi

if [ ! -f "$KIMI_BIN" ] && [ ! -f "${KIMI_BIN}.bin" ]; then
  echo "[!] 未找到 $KIMI_BIN"
  echo "    请先按官方方式安装 Kimi CLI（Linux arm64 版）"
  exit 1
fi

# 备份原始二进制
if [ -f "$KIMI_BIN" ] && [ ! -f "${KIMI_BIN}.bin" ]; then
  echo "[*] 备份 $KIMI_BIN -> ${KIMI_BIN}.bin"
  mv "$KIMI_BIN" "${KIMI_BIN}.bin"
fi

# 写 wrapper
echo "[*] 写入 wrapper: $KIMI_BIN"
cat > "$KIMI_BIN" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec "$RUNNER" "${KIMI_BIN}.bin" "\$@"
EOF

chmod +x "$KIMI_BIN"
hash -r 2>/dev/null || true

echo
echo "[✓] 安装完成"
echo "    验证: kimi --version"
"$KIMI_BIN" --version || true
