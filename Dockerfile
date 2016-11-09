# Base on Ubuntu 16.04 LTS
FROM ubuntu:xenial-20161010

# Yocto dependencies
RUN DEBIAN_FRONTEND="noninteractive" apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install -y \
        gawk wget git-core diffstat unzip texinfo gcc-multilib \
        build-essential chrpath socat libsdl1.2-dev xterm

# Install JRE 8
RUN DEBIAN_FRONTEND="noninteractive" apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends openjdk-8-jre-headless && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN mkdir /opt/jenkins
RUN wget -O /opt/jenkins/swarm-client-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/2.2/swarm-client-2.2-jar-with-dependencies.jar

# A minimal init system for Linux containers
#  https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

RUN useradd -m -d /var/build -s /bin/sh jenkins

USER jenkins
WORKDIR /var/build

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["java", "-jar", "/opt/jenkins/swarm-client-jar-with-dependencies.jar"]
