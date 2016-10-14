#!/bin/bash

function add_to_file {
    touch /root/.ssh/$1
    chmod 600 /root/.ssh/$1
    IFS=$'\n'
    arr=$(echo ${$2} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/$1 | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/$1: $x"
            echo "$x" >> /root/.ssh/$1
        fi
    done
}

if [ -n "${AUTHORIZED_KEYS}" ]; then
    echo "=> Found authorized keys"
    add_to_file authorized_keys ${AUTHORIZED_KEYS}
fi
if [ -n "${ADD_INSECURE_KEY}" ]; then
    echo "=> Adding insecure key to authorized ones"
    add_to_file authorized_keys `cat /root/.ssh/insecure_rsa.pub`
    echo "=> Adding insecure key as this container's id_rsa"
    add_to_file id_rsa `cat /root/.ssh/insecure_rsa`
fi

if [ -z "$SSHD_PORT" ]; then
  SSHD_PORT=22
fi

sed -i "s/Port.*/Port ${SSHD_PORT}/" /etc/ssh/sshd_config

echo 'Host any' > /root/.ssh/config
echo '  Hostname *' >> /root/.ssh/config
echo "  Port $SSHD_PORT" >> /root/.ssh/config

exec /usr/sbin/sshd -D
