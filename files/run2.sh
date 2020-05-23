#!/bin/bash

# Script from: https://github.com/TuRz4m/Ark-docker/blob/master/user.sh

# Change the UID if needed

if [ ! "$(id -u mc-server)" -eq "$UID" ]; then

        echo "Changing steam uid to $UID."

        usermod -o -u "$UID" mc-server ;

fi

# Change gid if needed

if [ ! "$(id -g mc-server)" -eq "$GID" ]; then

        echo "Changing steam gid to $GID."

        groupmod -o -g "$GID" mc-server ;

fi



# Put steam owner of directories (if the uid changed, then it's needed)

chown -R mc-server:mc-server /mc-server /buildtools /home/mc-server



# Launch run.sh with user steam (-p allow to keep env variables)

exec sudo -i -u mc-server /bin/bash - << %EOF%

# Cleanup old server versions!
rm -rf /mc-server/*.jar

# Install new server version
cp -af /buildtools/${SERVERTYPE}-${SERVERVERSION}.jar /mc-server/${SERVERTYPE}-${SERVERVERSION}.jar


# Check EULA
function CheckEULA {
        if [ ${EULA} != false ]; then
                if grep -Fxq "eula=false" /mc-server/eula.txt; then
                        sed -i '/eula=false/c\eula=true' /mc-server/eula.txt
                fi
        fi
}

function CreateEULAFile {
        if [ ${EULA} != false ]; then
                [ ! -f /mc-server/eula.txt ] && echo -n "eula=false" > /mc-server/eula.txt
        fi
}

CreateEULAFile
CheckEULA



%EOF%
