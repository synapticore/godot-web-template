FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget unzip ca-certificates fontconfig && \
    rm -rf /var/lib/apt/lists/*

# Godot 4.6 headless
RUN wget -O /tmp/godot.zip https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip && \
    unzip /tmp/godot.zip -d /usr/local/bin && \
    rm /tmp/godot.zip

# Export-Templates
RUN wget -O /tmp/templates.tpz https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates/4.6.stable && \
    unzip /tmp/templates.tpz -d /tmp && \
    mv /tmp/templates/* /root/.local/share/godot/export_templates/4.6.stable/ && \
    rm -rf /tmp/templates /tmp/templates.tpz

ENV GODOT_BIN=/usr/local/bin/Godot_v4.6-stable_linux.x86_64

WORKDIR /project
ENTRYPOINT ["/usr/local/bin/Godot_v4.6-stable_linux.x86_64", "--headless"]
