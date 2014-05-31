# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y software-properties-common && \
    echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    apt-get install -y oracle-java7-installer && \
    apt-get install -y nfs-common inotify-tools -qq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/cache/oracle-jdk7-installer
RUN adduser --quiet jenkins
RUN echo "jenkins:jenkins" | chpasswd
RUN echo 'root:jenkins' | chpasswd

RUN mkdir /etc/service/nfs-client
ADD nfs-client.sh /etc/service/nfs-client/run
RUN mkdir -p /mnt/nfs

ADD my_key_rsa.pub /tmp/ssh-key
RUN mkdir -p /home/jenkins/.ssh
RUN chown jenkins:users /home/jenkins/.ssh
RUN cat /tmp/ssh-key >> /home/jenkins/.ssh/authorized_keys && rm -f /tmp/your_key
RUN chown jenkins:users /home/jenkins/.ssh/authorized_keys && chmod 600 /home/jenkins/.ssh/authorized_keys

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
