ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    curl \
    wget \
    openssh-client \
    ca-certificates \
    dtach \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user for running Claude
RUN useradd -m -s /bin/bash claude

# Install ttyd
ARG TTYD_VERSION=1.7.7
RUN ARCH="$(uname -m)" \
    && wget -q "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ARCH}" -O /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# Install Claude Code CLI as the claude user (native standalone binary)
USER claude
ENV HOME="/home/claude"
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root
ENV PATH="/home/claude/.local/bin:${PATH}"
ENV CLAUDE_CONFIG_DIR="/home/claude/.claude"

# Copy root filesystem
COPY rootfs /

# Make scripts executable
RUN chmod +x /opt/claude-code/*.sh

# Labels
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
LABEL \
    io.hass.name="Claude Code" \
    io.hass.description="AI-powered terminal assistant for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION}
