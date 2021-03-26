FROM registry.access.redhat.com/ubi8/ubi-minimal
LABEL maintainer="ddoyle@redhat.com"

ENV RHOAS_CLI_PATH="/usr/local/bin/rhoas"
ENV OC_CLI_PATH="/usr/local/bin/oc"

# Install required packages
RUN microdnf install shadow-utils

# Create the RHOAS user
RUN useradd -ms /bin/bash rhoas
USER rhoas

COPY contrib/rhoas /usr/local/bin/rhoas
COPY contrib/oc /usr/local/bin/oc
COPY contrib/odo /usr/local/bin/odo
#RUN chown jboss:root -R /opt/data && chmod 777 -R /opt/data


