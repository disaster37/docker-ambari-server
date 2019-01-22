FROM centos:7
MAINTAINER Sebastien LANGOUREAUX (linuxworkgroup@hotmail.com)

# Application settings
ENV CONFD_PREFIX_KEY="/gocd" \
    CONFD_BACKEND="env" \
    CONFD_INTERVAL="60" \
    CONFD_NODES="" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    LANG="en_US.utf8" \
    APP_HOME="/etc/ambari-server" \
    APP_VERSION="2.7.3.0" \
    SCHEDULER_VOLUME="/opt/scheduler" \
    CONTAINER_NAME="ambari-server" \
    CONTAINER_AUHTOR="Sebastien LANGOUREAUX <linuxworkgroup@hotmail.com>" \
    CONTAINER_SUPPORT="" \
    APP_WEB=""

# Install extra package
RUN yum install -y curl tar bash git 

# Install confd
ENV CONFD_VERSION="0.14.0" \
    CONFD_HOME="/opt/confd"
RUN mkdir -p "${CONFD_HOME}/etc/conf.d" "${CONFD_HOME}/etc/templates" "${CONFD_HOME}/log" "${CONFD_HOME}/bin" &&\
    curl -Lo "${CONFD_HOME}/bin/confd" "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" &&\
    chmod +x "${CONFD_HOME}/bin/confd"

# Install s6-overlay
RUN curl -Lo /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz &&\
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" &&\
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin


# Install Ambari server
RUN \
    curl -Lo /etc/yum.repos.d/ambari.repo "http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/${APP_VERSION}/ambari.repo"
RUN yum install -y ambari-server postgresql java-1.8.0-openjdk-devel krb5-workstation krb5-libs
RUN  ambari-server setup --silent --java-home=/usr/lib/jvm/java --database=postgres --databasehost=db --databaseport=5432 --databasename=ambari \
    --databaseusername=ambari --databasepassword=ambari

ADD root /

EXPOSE 8080
VOLUME /etc/ambari-server/.init

CMD ["/init"]