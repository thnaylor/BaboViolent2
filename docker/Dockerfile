# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake pkg-config \
        libgl1-mesa-dev libglu1-mesa-dev \
        libsdl2-mixer-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN cmake -S . -B build-linux \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    && cmake --build build-linux \
        --target BaboViolentDedicated \
        -j"$(nproc)"

# ── Stage 2: runtime ─────────────────────────────────────────────────────────
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        libsdl2-mixer-2.0-0 \
        libglu1-mesa \
        libgl1 \
        curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build-linux/BaboViolentDedicated /app/BaboViolentDedicated
COPY Content/ /app/Content/
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN sed -i 's/\r//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

WORKDIR /app/Content

EXPOSE 3339/tcp
EXPOSE 3339/udp

ENTRYPOINT ["/app/entrypoint.sh"]
