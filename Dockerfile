FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        libsdl2-mixer-2.0-0 \
        libglu1-mesa \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

COPY build-linux/BaboViolentDedicated /app/BaboViolentDedicated
COPY Content/ /app/Content/
# Disable public master-server registration — not needed for a local/LAN server
# and the DNS timeout blocks the game loop for ~15 s on every startup.
RUN sed -i 's/set sv_gamePublic true/set sv_gamePublic false/g' \
        /app/Content/main/LaunchScript/FFA.cfg \
        /app/Content/main/LaunchScript/CTF.cfg \
        /app/Content/main/LaunchScript/TDM.cfg \
        /app/Content/main/LaunchScript/Champion.cfg 2>/dev/null; true

WORKDIR /app/Content

EXPOSE 3334/tcp
EXPOSE 3334/udp

ENTRYPOINT ["/app/BaboViolentDedicated"]
CMD ["FFA"]
