FROM registry.access.redhat.com/ubi8/ubi as builder

RUN yum update -y && yum install \
	git gcc gcc-c++ python3 \
	cyrus-sasl-devel make \
	tar wget \
	cmake diffutils curl-devel -y

COPY ./install-rhoas.sh .

ARG RHOAS_VERSION
RUN RHOAS_CLI_PATH=/opt/rhoas TAG=$RHOAS_VERSION ./install-rhoas.sh

#Using version 1.6 of Kafkacat. Build from master has an issue where it doesn't accept input in producer mode until you hit Ctrl-D.
RUN git clone --depth 1 --branch 1.6.0 https://github.com/edenhill/kafkacat /opt/kafkacat    
RUN pushd /opt/kafkacat && ./bootstrap.sh

# ---------------------------------------------------------------------------- #

FROM registry.access.redhat.com/ubi8/ubi-minimal
LABEL maintainer="ddoyle@redhat.com"

ENV RHOAS_CLI_PATH="/usr/local/bin/rhoas"
ENV OC_CLI_PATH="/usr/local/bin/oc"

# Install required packages
RUN microdnf install shadow-utils yum jq

# Create the RHOAS user
RUN useradd -ms /bin/bash rhoas
USER rhoas

COPY contrib/oc /usr/local/bin/oc
COPY contrib/odo /usr/local/bin/odo
COPY --from=builder --chown=root:root /opt/rhoas ${RHOAS_CLI_PATH}
COPY scripts /usr/local/bin

USER root
RUN mkdir -p /.config/rhoas && chmod 777 -R /.config/rhoas && echo "{}" > /.config/rhoas/config.json && chmod 777 /.config/rhoas/config.json
RUN mkdir /.kube && chmod 777 /.kube
USER rhoas

COPY --from=builder --chown=root:root /opt/kafkacat/kafkacat /usr/local/bin/kafkacat

ENTRYPOINT ["tail", "-f", "/dev/null"]
