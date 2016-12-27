FROM alpine:latest
MAINTAINER cnnblike "cnnblike@gmail.com"
RUN apk update && apk add openssh nginx supervisor git bash openssl
RUN ssh-keygen -A
RUN sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
RUN sed -i "s/^#AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/g" /etc/ssh/sshd_config
RUN sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" /etc/ssh/sshd_config

RUN mkdir /var/repo && cd /var/repo && git init --bare blog.git
RUN mkdir /var/www/html
COPY post-receive /var/repo/blog.git/hooks/post-receive
RUN chmod +x /var/repo/blog.git/hooks/post-receive

RUN cd /var/repo && git init --bare config.git
COPY config-post-receive /var/repo/config.git/hooks/post-receive
RUN chmod +x /var/repo/config.git/hooks/post-receive

COPY blog.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

RUN mkdir /run/nginx
COPY supervisord.conf /etc/supervisord.conf
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
EXPOSE 22 80 443
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

