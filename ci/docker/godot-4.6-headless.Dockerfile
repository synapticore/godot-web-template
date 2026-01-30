FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Godot 4.6 headless
RUN wget -O /tmp/godot.zip https://downloads.tuxfamily.org/godotengine/4.6/Godot_v4.6-stable_linux.x86_64.zip && \
    unzip /tmp/godot.zip -d /usr/local/bin && \
    rm /tmp/godot.zip

# Export-Templates
RUN wget -O /tmp/templates.tpz https://downloads.tuxfamily.org/godotengine/4.6/Godot_v4.6-stable_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates/4.6.stable && \
    unzip /tmp/templates.tpz -d /root/.local/share/godot/export_templates/4.6.stable && \
    rm /tmp/templates.tpz

ENV GODOT_BIN=/usr/local/bin/Godot_v4.6-stable_linux.x86_64

WORKDIR /project
ENTRYPOINT ["sh", "-c", "$GODOT_BIN --headless $*"]
