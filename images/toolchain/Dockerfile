# check=error=true

# Each tool ships as its own image; naming them as stages lets Dependabot bump every digest.
FROM ghcr.io/astral-sh/uv:0.12.23@sha256:61d393e44e249f2e4b526b6c7ddcecce245946826e608e11c93ad4f5bba55b21 AS uv
FROM koalaman/shellcheck:v0.11.0@sha256:61862eba1fcf09a484ebcc6feea46f1782532571a34ed51fedf90dd25f925a8d AS shellcheck
FROM mvdan/shfmt:v3.14.1@sha256:8c06884a35683d8763fba6c0d9484d11a61a96da65f8d497d6f625825a6043f2 AS shfmt
FROM hadolint/hadolint:v2.15.1@sha256:32dac94127fd60b7b7e3fbfc65e1383b9b5e25c9bfd7b8536de7a539fe68a12d AS hadolint
FROM rhysd/actionlint:1.7.12@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667 AS actionlint
FROM ghcr.io/gitleaks/gitleaks:v8.30.1@sha256:c00b6bd0aeb3071cbcb79009cb16a60dd9e0a7c60e2be9ab65d25e6bc8abbb7f AS gitleaks
FROM ghcr.io/google/osv-scanner:v2.6.0@sha256:afd838850ac1a0fcc15ff4a041dc9ba11123c3f0d2666217a5f0fcf9222b55fa AS osv-scanner
FROM lycheeverse/lychee:0.24.2@sha256:e2d19e57cf6ab037026f20b8e449a1f30d9d7f81eef4194763aab2eab20bd28d AS lychee
FROM tamasfe/taplo:0.10.0@sha256:e0e247250609d2c0f3a77bc8003dc21eaa16ffd1b07ef4bad16c35f6845eec2b AS taplo

# GitHub's runner runs JavaScript actions on its own glibc build of Node, mounted into a job's
# container. scripts/consumer.sh mounts this official build the same way; the image never copies it.
FROM node:24.21.0-trixie-slim@sha256:173f125896c3b47ddf056734c7ea789d04595a6a08769a8f78e0df642781fb66 AS actions-node

# Wolfi links glibc, so GitHub's runner can still host JavaScript actions in the job container on
# arm64, which Alpine's musl would break. Its packages split finer than Debian's: git arrives without
# perl, and Node links the system's ICU and OpenSSL rather than embedding its own.
FROM cgr.dev/chainguard/wolfi-base:latest@sha256:c08875f557c44f2e376d40ab68a6674234a8eeef06a0d10fbe9d2db40bcdb531 AS base

# Each package floats within the line its name fixes, and the upgrade refreshes the base's own, so the
# weekly rebuild takes fixes; .hadolint.yaml explains why nothing pins them further.
RUN apk upgrade --no-cache \
    && apk add --no-cache bash corepack git nodejs-24 npm python-3.14 \
    && adduser -D -u 1000 -h /home/toolchain toolchain

# Vale's own image links against musl, so take the release build. Dependabot cannot bump these
# downloads: change the version and both checksums together.
FROM base AS vale-amd64
ADD --checksum=sha256:867534ddb678abca7f214bc4706ead0922bd5252ffe8035fc227013f66c8b214 \
    https://github.com/errata-ai/vale/releases/download/v3.24.0/vale_3.24.0_Linux_64-bit.tar.gz /tmp/vale.tar.gz

FROM base AS vale-arm64
ADD --checksum=sha256:104cbd349279e50c4cb40adb70adf345d93cc4a3a0191f9e68bdccb97086b582 \
    https://github.com/errata-ai/vale/releases/download/v3.24.0/vale_3.24.0_Linux_arm64.tar.gz /tmp/vale.tar.gz

# hadolint reads the per-architecture stage name as an untagged image.
# hadolint ignore=DL3006
FROM vale-${TARGETARCH} AS vale
RUN tar -xzf /tmp/vale.tar.gz -C /tmp vale

FROM base AS node-tools
WORKDIR /opt/toolchain/node
COPY node/package.json node/package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund

# The venv links to base's interpreter by absolute path, which the final stage shares. uv only builds
# it, so the image never carries uv itself.
FROM base AS python-tools
COPY --from=uv /uv /usr/local/bin/
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/toolchain/python/venv \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON_PREFERENCE=only-system
WORKDIR /opt/toolchain/python
COPY python/pyproject.toml python/uv.lock python/.python-version ./
RUN uv sync --frozen --no-dev

FROM base

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable

COPY --from=shellcheck /bin/shellcheck /usr/local/bin/
COPY --from=shfmt /bin/shfmt /usr/local/bin/
COPY --from=hadolint /bin/hadolint /usr/local/bin/
COPY --from=actionlint /usr/local/bin/actionlint /usr/local/bin/
COPY --from=gitleaks /usr/bin/gitleaks /usr/local/bin/
COPY --from=osv-scanner /osv-scanner /usr/local/bin/
COPY --from=vale /tmp/vale /usr/local/bin/
COPY --from=lychee /usr/local/bin/lychee /usr/local/bin/
COPY --from=taplo /taplo /usr/local/bin/
COPY --from=node-tools /opt/toolchain/node /opt/toolchain/node
COPY --from=python-tools /opt/toolchain/python /opt/toolchain/python

ENV PATH=/opt/toolchain/node/node_modules/.bin:/opt/toolchain/python/venv/bin:$PATH

# The `toolchain` user, by number so a runtime can verify it is not root.
USER 1000
WORKDIR /workspace
