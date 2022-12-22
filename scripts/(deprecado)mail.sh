# /opt/ups/mail.sh

#!/bin/bash

source config

function mailSend() {
    TMP_FILE="/tmp/ups.email"
    /bin/echo "To: $MAIL_NAME <$MAIL_RCPT>" > $TMP_FILE
    /bin/echo "Subject: $1" >> $TMP_FILE
    /bin/echo "" >> $TMP_FILE
    /bin/echo "$2" >> $TMP_FILE

    /usr/sbin/sendmail -v $MAIL_RCPT < $TMP_FILE

    /bin/rm $TMP_FILE
}