#!/usr/bin/with-contenv ash

NAS_IP=${NAS_IP:-""}
NAS_SSH_PORT=${NAS_SSH_PORT:-"22"}
NAS_SSH_USER=${NAS_SSH_USER:-"root"}
NAS_SSH_PASS=${NAS_SSH_PASS:-""}

SOURCE_DATA_PATH=${SOURCE_DATA_PATH:-""}
REMOTE_DATA_PATH=${REMOTE_DATA_PATH:-""}

[ "x$NAS_IP" == "x" ] && exit 1
[ "x$NAS_SSH_PASS" == "x" ] && exit 1
[ "x$SOURCE_DATA_PATH" == "x" ] && exit 1
[ "x$REMOTE_DATA_PATH" == "x" ] && exit 1

for SOURCE in $SOURCE_DATA_PATH;
do
DST=$(basename $SOURCE)
sshpass -p "$NAS_SSH_PASS" ssh -oStrictHostKeyChecking=no -p $NAS_SSH_PORT $NAS_SSH_USER@$NAS_IP <<ENDSSH
    mkdir -p $REMOTE_DATA_PATH/$DST;
    cd $REMOTE_DATA_PATH/$DST;
    LATEST=$(ls -1d current.$(date +"%y%m")?? | sort -r | head -1)
    [ ! -d "current.$(date +"%y%m%d")" ] && [ -d "$LATEST" ] && cp -rp $LATEST current.$(date +"%y%m%d");
    exit
ENDSSH

sshpass -p "$NAS_SSH_PASS" rsync -e "ssh -oStrictHostKeyChecking=no -p $NAS_SSH_PORT" -azP $SOURCE $NAS_SSH_USER@$NAS_IP:$REMOTE_DATA_PATH/$DST/current.$(date +"%y%m%d")
if [ $? == 0 ] 
then
    echo "Done"
else
    pkill -P 0
fi
done
