FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive
# Set $PATH so that non-login shells will see the Ruby binaries
ENV PATH $PATH:/opt/rubies/ruby-2.1.2/bin

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN apt-get update

# Install build dependencies
RUN apt-get install -y \
  wget \
  build-essential \
  libcurl4-openssl-dev \
  python-dev \
  python-setuptools \
  python-software-properties \
  software-properties-common

# Add official git and nginx APT repositories
RUN apt-add-repository ppa:git-core/ppa
RUN apt-add-repository ppa:nginx/stable
# Add Chris Lea NodeJS repository
RUN apt-add-repository ppa:chris-lea/node.js

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

# Install ruby-install
RUN cd /tmp &&\
  wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz &&\
  tar -xzvf ruby-install-0.4.3.tar.gz &&\
  cd ruby-install-0.4.3/ &&\
  make install

RUN apt-get update

# Install git
RUN apt-get install -y git

# Install MRI Ruby 2.1.2
RUN ruby-install ruby 2.1.2

# Add Ruby binaries to $PATH
ADD ./ruby.sh /etc/profile.d/ruby.sh
RUN chmod a+x /etc/profile.d/ruby.sh

# Install bundler gem globally
RUN /bin/bash -l -c 'gem install bundler'

# Install Ruby application dependencies
RUN apt-get install -y \
  git \
  libpq-dev \
  postgresql-client-9.3 \
  nodejs \
  libreadline-dev \
  zlib1g-dev \
  flex \
  bison \
  libxml2-dev \
  libxslt1-dev \
  libssl-dev \
  imagemagick \
  nginx \
  supervisor

# Run nginx in foreground
RUN echo "daemon off;\n" >> /etc/nginx/nginx.conf
ADD supervisor.conf /etc/supervisor/conf.d/nginx.conf

# Clean up APT and temporary files when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/data", "/var/log/nginx", "/var/log/supervisor"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]

EXPOSE 80
