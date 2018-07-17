FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y --no-install-recommends --no-install-suggests install \
      openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/run/sshd && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

ADD entrypoint.sh /root/.ssh/
ADD insecure_rsa /root/.ssh/
ADD insecure_rsa.pub /root/.ssh/
ADD stopsshd /usr/bin/

RUN chmod 600 /root/.ssh/insecure_rsa

ENTRYPOINT ["/root/.ssh/entrypoint.sh"]
