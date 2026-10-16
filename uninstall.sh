#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

KIMI_BIN="$HOME/.kimi-code/bin/kimi"

if [ -f "${KIMI_BIN}.bin" ]; then
  echo "[*] 还原 ${KIMI_BIN}.bin -> $KIMI_BIN"
  rm -f "$KIMI_BIN"
  mv "${KIMI_BIN}.bin" "$KIMI_BIN"
  echo "[✓] 已还原"
else
  echo "[!] 未找到 ${KIMI_BIN}.bin，跳过"
fi

read -rp "是否卸载 glibc-runner? [y/N] " yn
case "$yn" in
  [Yy]*) pkg uninstall -y glibc-runner glibc-repo || true ;;
esac

hash -r 2>/dev/null || true
