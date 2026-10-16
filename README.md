# termux-kimi-cli

在 **Termux / Android (aarch64)** 上运行 [Kimi CLI](https://github.com/MoonshotAI/kimi-cli) 的最小方案。

修复典型报错：

```
zsh: no such file or directory: /data/data/com.termux/files/home/.kimi-code/bin/kimi
```

## 问题原因

Kimi CLI 官方 Linux 版是 **glibc 动态链接** 的 ELF：

```
$ file ~/.kimi-code/bin/kimi
ELF 64-bit LSB executable, ARM aarch64, ...
interpreter /lib/ld-linux-aarch64.so.1
```

而 Termux 用的是 Android bionic（`/system/bin/linker64`），内核找不到 `ld-linux-aarch64.so.1`，于是直接返回 `ENOENT`，shell 就显示成 “no such file or directory”。

注意：`which kimi` 能找到，`ls -l` 也能看到，但 **执行** 一定失败。不是权限、不是 PATH、不是 chmod 能解决的。

## 解决思路

用 `glibc-runner` 在 Termux 里补一个 glibc 运行环境，再用 wrapper 把 `kimi` 命令转发过去。

## 安装

```bash
git clone https://github.com/<你的用户名>/termux-kimi-cli.git
cd termux-kimi-cli
bash install.sh
```

`install.sh` 会：

1. `pkg install glibc-repo glibc-runner`
2. 备份原始 `~/.kimi-code/bin/kimi` → `kimi.bin`
3. 在原位置放一个 wrapper，把参数转发给 `glibc-runner kimi.bin`

安装后验证：

```bash
kimi --version
```

## 手动安装（不想用脚本）

```bash
pkg install glibc-repo
pkg install glibc-runner

P=~/.kimi-code/bin/kimi
mv "$P" "$P.bin"

cat > "$P" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec glibc-runner /data/data/com.termux/files/home/.kimi-code/bin/kimi.bin "$@"
EOF

chmod +x "$P"
hash -r
```

## 卸载

```bash
bash uninstall.sh
```

会把 `kimi.bin` 还原成 `kimi`，并可选卸载 `glibc-runner`。

## 为什么不用 proot-distro？

`proot-distro` 也能跑，但要装整套 Ubuntu，慢、占空间。`glibc-runner` 更轻量。如果 `glibc-runner` 跑不起来（缺库、版本不兼容），再考虑 proot。

## 已知问题

- 首次运行 `glibc-runner` 会解压 glibc 环境，稍慢。
- 如果提示缺 `.so`，试试 `glibc-runner -f`，或改用 `proot-distro`。
- 仅测试于 **aarch64** 设备，x86_64 模拟器未验证。

## License

MIT
