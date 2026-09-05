# ============================================================
# Oh-My-Pi (omp) coding agent + ompweb Web UI
# Base: Debian stable, user: root
#
# omp installed via official https://omp.sh/install script
# ompweb runs via the published npm package (bin: ompweb)
# ============================================================
FROM debian:stable

# --- Build args (injected by CI; default to latest) ---
ARG OMPWEB_VERSION=latest

# --- User / working dir ---
USER root
WORKDIR /root

# --- System packages ---
# curl: for omp install script
# git, build-essential, python3, python3-pip, python3-venv: dev tooling
# ca-certificates, gnupg, wget: for nodejs setup
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        wget \
        git \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        procps \
        nano \
        vim \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js (LTS, >= 22.19.0 required by ompweb) ---
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- Bun (optional but useful for omp ecosystem) ---
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# --- Oh-My-Pi coding agent (official install script) ---
RUN curl -fsSL https://omp.sh/install | sh

# --- ompweb (global install via npm) ---
RUN npm install -g @kahme247/ompweb@${OMPWEB_VERSION}

# --- Runtime ---
ENV NODE_ENV=production \
    OMP_WEB_HOSTNAME=0.0.0.0 \
    OMP_WEB_NO_OPEN=1
EXPOSE 30177

# --- Healthcheck ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:30177/ >/dev/null 2>&1 || exit 1

# ompweb binds to 0.0.0.0:30177 (reachable from host)
CMD ["ompweb", "--hostname", "0.0.0.0", "--no-open"]
