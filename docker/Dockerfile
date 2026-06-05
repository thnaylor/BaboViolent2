FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        libsdl2-mixer-2.0-0 \
        libglu1-mesa \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

COPY build-linux/BaboViolentDedicated /app/BaboViolentDedicated
COPY Content/ /app/Content/
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

WORKDIR /app/Content

EXPOSE 3333/tcp
EXPOSE 3333/udp

ENTRYPOINT ["/app/entrypoint.sh"]
