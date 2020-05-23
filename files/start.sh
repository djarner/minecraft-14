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



# avoid error message when su -p (we need to read the /root/.bash_rc )

chmod -R 777 /root/

# Launch run.sh with user steam (-p allow to keep env variables)

su -p - mc-server -c /home/mc-server/run.sh
