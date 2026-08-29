# ChromeOSFetch v1.0.0

Initial release of ChromeOSFetch.

## Features

- Native ChromeOS system information from the developer shell
- ChromeOS version and architecture
- Chromebook board / HWID detection
- Kernel and uptime
- CPU and GPU information
- Memory usage
- Display resolution detection
- Battery percentage and charging state
- Root filesystem usage
- Bash-only design that can run with `bash chromeosfetch.sh` even from common ChromeOS `noexec` user-writable locations

## Install

```bash
curl -L -o chromeosfetch.sh https://raw.githubusercontent.com/Kaydn913/ChromeOSFetch/main/chromeosfetch.sh
bash chromeosfetch.sh
```
