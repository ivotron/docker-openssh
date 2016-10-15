#!/bin/bash

if [ -n "${AUTHORIZED_KEYS}" ]; then
    echo "=> Found authorized keys"
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

if [ -n "${ADD_INSECURE_KEY}" ]; then
    echo "=> Adding insecure key to authorized ones"
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    cat /root/.ssh/insecure_rsa.pub >> /root/.ssh/authorized_keys

    echo "=> Adding insecure key as this container's id_rsa"
    mv /root/.ssh/insecure_rsa /root/.ssh/id_rsa
fi

if [ -z "$SSHD_PORT" ]; then
  SSHD_PORT=22
fi

sed -i "s/Port.*/Port ${SSHD_PORT}/" /etc/ssh/sshd_config

echo 'Host any' > /root/.ssh/config
echo '  Hostname *' >> /root/.ssh/config
echo "  Port $SSHD_PORT" >> /root/.ssh/config

exec /usr/sbin/sshd -D
