#!/bin/bash
DEBUG=0

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
export PATH
TZ='America/Santiago'
export TZ

function log() {
  if [ $DEBUG -eq 1 ];
  then
    logger $1;
  fi
}

log "ups_event.sh: running"

cd /opt/ups
source config
log "ups_event.sh: loaded config"
source mail.sh
log "ups_event.sh: loadad mail.sh"

MESSAGE_MAIL=""
EVENT_TYPE=$1
APAGADO="0"
FECHA=$(/bin/date '+%Y-%m-%d %H:%M:%S%z')

case "$EVENT_TYPE" in
    "ups-on-battery-shutdown")
        MESSAGE_MAIL="UPS on battery: shutdown now"
        APAGADO="1"
        ;;
    "ups-on-battery")
        MESSAGE_MAIL="WARN: UPS on battery"
        ;;
    "ups-comunication-bad")
        MESSAGE_MAIL="Communications with UPS lost"
        ;;
    "ups-change_battery")
        MESSAGE_MAIL="UPS battery needs to be replaced"
        ;;
    "ups-back-on-line")
        MESSAGE_MAIL="INFO: UPS on line power"
        ;;
    "ups-low-battery")
        MESSAGE_MAIL="UPS battery is low"
        ;;
    "ups-comunication-ok")
        MESSAGE_MAIL="Communications with UPS established"
        ;;
esac

log "ups_event.sh: case finished, sending email..."
mailSend  "[$FECHA] $MESSAGE_MAIL"  "[UPS] Event $EVENT_TYPE de SAI IoT GW $GW_ID"
/bin/echo "[$FECHA] SAI: $MESSAGE_MAIL" >> /var/log/ups.log
log "ups_event.sh: mail sent, waiting.."

if [ $APAGADO = "1" ]
then
    /bin/sleep 30
    /opt/ups/halt_server.sh
fi
log "ups_event.sh: everything done, exit."

exit 0