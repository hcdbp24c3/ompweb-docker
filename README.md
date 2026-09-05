# ompweb Docker Image

Auto-built Docker image for [oh-my-pi (omp)](https://github.com/can1357/oh-my-pi) coding agent + [ompweb](https://github.com/kahme247/ompweb) Web UI.

## Image

**Registry:** `ghcr.io/hcdbp24c3/ompweb-docker`

**Tags:**
- `latest` — newest build
- `<ompweb-version>` — e.g. `0.4.2`

**Architectures:** `linux/amd64`, `linux/arm64`

## Features

- Base: `debian:stable`, runs as `root`
- Installs:
  - Oh-My-Pi coding agent (via official `https://omp.sh/install`, pinned to exact version with `--binary --ref`)
  - ompweb Web UI (via `npm install -g @kahme247/ompweb`)
  - Node.js 22 LTS, Bun, Python 3, git, build tools
- ompweb binds to `0.0.0.0:30177`

## Usage

```bash
docker pull ghcr.io/hcdbp24c3/ompweb-docker:latest

docker run -d \
  --name ompweb \
  -p 30177:30177 \
  -v omp-data:/root/.omp \
  ghcr.io/hcdbp24c3/ompweb-docker:latest
```

Then open <http://localhost:30177>.

### Optional: Password Protection

```bash
docker run -d \
  --name ompweb \
  -p 30177:30177 \
  -e OMP_WEB_PASSWORD='your-password' \
  -v omp-data:/root/.omp \
  ghcr.io/hcdbp24c3/ompweb-docker:latest
```

### Optional: Custom Working Directory

```bash
docker run -d \
  --name ompweb \
  -p 30177:30177 \
  -v omp-data:/root/.omp \
  -v /path/to/your/project:/workspace \
  -w /workspace \
  ghcr.io/hcdbp24c3/ompweb-docker:latest
```

## How auto-build works

A GitHub Actions workflow (`.github/workflows/build.yml`) runs:

- **Every 6 hours** (cron) and on **manual dispatch**
- Queries the npm registry for the latest versions of:
  - `@kahme247/ompweb` (Web UI)
  - `@oh-my-pi/pi-coding-agent` (omp coding agent — same version as the `omp.sh/install` release tag)
- Compares them against the last-built versions committed in `VERSIONS`
- If a new version is found (or `force: true` on manual dispatch):
  - Builds a multi-arch image (`linux/amd64`, `linux/arm64`)
  - Pushes to GHCR with tags `<ompweb-version>` and `latest`
  - Commits the new versions back to `VERSIONS`

### Manual trigger

```bash
gh workflow run build.yml --repo hcdbp24c3/ompweb-docker
# or force a rebuild even if versions are unchanged:
gh workflow run build.yml --repo hcdbp24c3/ompweb-docker -f force=true
```

## Local build

```bash
docker build -t ompweb .
docker run -p 30177:30177 ompweb
```
