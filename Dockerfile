FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

# Set $PATH so that non-login shells will see the Ruby binaries
ENV PATH $PATH:/opt/rubies/ruby-2.1.2/bin

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN locale-gen en_US.UTF-8 &&\
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales &&\
# Install build dependencies
  apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  wget \
  build-essential \
  libcurl4-openssl-dev \
  python-dev \
  python-setuptools \
  python-software-properties \
  software-properties-common &&\
# Add official git and nginx APT repositories
  apt-add-repository ppa:git-core/ppa &&\
  apt-add-repository ppa:nginx/stable &&\
# Add Chris Lea NodeJS repository
  apt-add-repository ppa:chris-lea/node.js &&\
# Add PostgreSQL Global Development Group apt source
  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list &&\
# Add PGDG repository key
  wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add - &&\
# Install ruby-install
  cd /tmp &&\
  wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz &&\
  tar -xzvf ruby-install-0.4.3.tar.gz &&\
  cd ruby-install-0.4.3/ &&\
  make install &&\
# Update apt cache with PPAs
  apt-get update &&\
# Install git
  DEBIAN_FRONTEND=noninteractive apt-get install -y git &&\
# Install MRI Ruby 2.1.2
  ruby-install ruby 2.1.2 &&\
# Install bundler globally
  /bin/bash -l -c 'gem install bundler' &&\
# Install Ruby application dependencies
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
  supervisor &&\
# Run nginx in foreground
  echo "daemon off;\n" >> /etc/nginx/nginx.conf &&\
# Clean up APT and temporary files when done
  apt-get clean &&\
  DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y wget &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Ruby binaries to login shells's $PATH
COPY ./ruby.sh /etc/profile.d/ruby.sh

# Add nginx to supervisord supervision
COPY supervisor.conf /etc/supervisor/conf.d/nginx.conf

VOLUME ["/data", "/var/log/nginx", "/var/log/supervisor"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]

EXPOSE 80
