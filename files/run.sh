#!/usr/bin/env bash

# Initial setup
cp -a /buildtools/$SERVERTYPE-$SERVERVERSION.jar /mc-server/$SERVERTYPE-$SERVERVERSION.jar

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

java -Xms${MINMEMORY} -Xmx${MAXMEMORY} -XX:+UseConcMarkSweepGC -jar ${SERVERTYPE}-${SERVERVERSION}.jar
