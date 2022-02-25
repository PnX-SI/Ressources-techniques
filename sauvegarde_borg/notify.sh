#!/usr/bin/bash
#
# Notify user of borgmatic backup status.
#
# ~/.config/borgmatic/notify.sh "{configuration_filename}" "{repository}" "{error}" "{output} {status}"
# variable error and output are set only if its a error hook

if [ "$5" != "error" ]; then
  error_msg=""
else
   error_msg="une errur
   Error Message, if any: $3 
   Command output, if any: $4    
   For more information, query the systemd journal on {$HOSTNAME}
   "
fi



sendmail <RECIPIENT_EMAIL> <<EOF
From: <SENDER_EMAIL>
Subject: Backup $5 on ${HOSTNAME}
Borgmatic backup on ${HOSTNAME} $5.

Configuration file: $1

Repository: $2

$error_msg

EOF

