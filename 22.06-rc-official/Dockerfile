FROM docker:rc-dind

RUN apk add --no-cache sudo bash bash-completion curl \ 
	git nano wget unzip ca-certificates wget && \
	rm -rf /var/cache/*/* && \
	rm -rf /root/.ash_history

RUN addgroup -g 1000 alpine && addgroup -S docker \
	&& adduser -u 1000 -G alpine -h /home/alpine -D alpine \
	&& sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd \
	&& echo "alpine ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
	&& echo "root":"root" | chpasswd && echo "alpine":"alpine" | chpasswd \
	&& adduser alpine wheel && adduser alpine root && adduser alpine docker

RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/1.2.2/terraform_1.2.2_linux_amd64.zip && \
	unzip terraform.zip && \
	cp -a terraform /usr/bin && \
	rm -rf terraform.zip

COPY --chown=alpine:alpine ./.bashrc /home/alpine/.bashrc
COPY --chown=alpine:alpine ./.bash_profile /home/alpine/.bash_profile
COPY --chown=root:root ./.bashrc /root/.bashrc
COPY --chown=root:root ./.bash_profile /root/.bash_profile

USER root

WORKDIR /home/alpine

VOLUME ["/var/lib/docker", "/home/alpine"]

ENTRYPOINT ["sudo", "dockerd-entrypoint.sh"]

CMD ["--tls=false"]
