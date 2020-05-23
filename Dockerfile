# Henrik Djarner 17-07-2019

FROM openjdk:8-jdk-stretch

ENV MINMEMORY=512M
ENV MAXMEMORY=1G

# Spigot or CraftBukkit version
ENV SERVERVERSION 1.14.4
# Server type: craftbukkit or spigot. Default: spigot
ENV SERVERTYPE spigot

# EULA Settings: https://account.mojang.com/documents/minecraft_eula
ENV EULA true

# UID and GID of the user mc-server
ENV UID 1000
ENV GID 1000

# EXPOSE server default port
EXPOSE 25565

# Install needed dependencies, create User, install dumb init (https://github.com/Yelp/dumb-init)
RUN apt-get update -y && \
    apt-get install -y git && \
    apt-get install -y wget && \
    apt-get install -y sudo && \
    apt-get clean && \
    adduser \
      --disabled-login \
      --shell /bin/bash \
      --gecos "" \
      mc-server && \
    sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
      /etc/sudoers && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init

# Default structure
ADD files/run2.sh /home/mc-server/run.sh
RUN usermod -a -G sudo mc-server && \
    mkdir -p /buildtools && \
    mkdir -p /mc-server && \
    chown mc-server -R /buildtools && \
    chown mc-server -R /mc-server && \
    chmod +x /home/mc-server/run.sh

# Store for all server specific data
VOLUME ["/mc-server"]

# Spigot BuildTools reference: https://www.spigotmc.org/wiki/buildtools/
WORKDIR /buildtools

# Latest builds available on: https://www.spigotmc.org/wiki/buildtools/#versions
RUN wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
    git config --global core.autocrlf false && \
    java -jar BuildTools.jar --rev $SERVERVERSION && \
    rm -rf /buildtools/BuildTools.jar && \
    rm -rf /buildtools/BuildData && \
    rm -rf /buildtools/BuildTools.log.txt && \
    rm -rf /buildtools/Bukkit && \
    rm -rf /buildtools/CraftBukkit && \
    rm -rf /buildtools/Spigot && \
    rm -rf /buildtools/apache-* && \
    rm -rf /buildtools/work

# Spigot Server reference: https://www.spigotmc.org/wiki/spigot-installation/
WORKDIR /mc-server

# Reference: https://docs.docker.com/engine/reference/builder/#entrypoint
# We need to run this script as root to probably change the UID and GID after we will switch to the mc-server user.

# Usage:
# ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
# CMD ["bash", "-c", "do-some-pre-start-thing && exec my-server"]

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

# Har læst at det kan hjælpe tilføje "--noconsole" til sidst for at undgå 100% CPU usage
CMD ["bash", "-c", "/home/mc-server/run.sh && java -Xms${MINMEMORY} -Xmx${MAXMEMORY} -XX:+UseConcMarkSweepGC -jar /mc-server/${SERVERTYPE}-${SERVERVERSION}.jar nogui --noconsole"]
