FROM registry.access.redhat.com/ubi8/ubi as builder

RUN dnf install \
	git gcc gcc-c++ python3 \
	cyrus-sasl-devel make \
	cmake diffutils curl-devel -y

#Using version 1.6 of Kafkacat. Build from master has an issue where it doesn't accept input in producer mode until you hit Ctrl-D.
RUN git clone --depth 1 --branch 1.6.0 https://github.com/edenhill/kafkacat /opt/kafkacat    
RUN pushd /opt/kafkacat && ./bootstrap.sh

# ---------------------------------------------------------------------------- #

FROM registry.access.redhat.com/ubi8/ubi-minimal
LABEL maintainer="ddoyle@redhat.com"

ENV RHOAS_CLI_PATH="/usr/local/bin/rhoas"
ENV OC_CLI_PATH="/usr/local/bin/oc"

# Install required packages
RUN microdnf install shadow-utils jq

# Create the RHOAS user
RUN useradd -ms /bin/bash rhoas
USER rhoas

COPY contrib/rhoas /usr/local/bin/rhoas
COPY contrib/oc /usr/local/bin/oc
COPY contrib/odo /usr/local/bin/odo

USER root
RUN mkdir -p /.config/rhoas && chmod 777 -R /.config/rhoas && echo "{}" > /.config/rhoas/config.json && chmod 777 /.config/rhoas/config.json
RUN mkdir /.kube && chmod 777 /.kube
USER rhoas
WORKDIR /home/rhoas

COPY scripts /home/rhoas/scripts
COPY --from=builder --chown=root:root /opt/kafkacat/kafkacat /usr/local/bin/kafkacat

ENTRYPOINT ["tail", "-f", "/dev/null"]
