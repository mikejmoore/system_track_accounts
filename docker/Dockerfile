FROM ruby:2.2.3

ENV SQL_HOST system-track-accounts-db
ENV SQL_HOST_PORT 3306

ENV DOCKER_IMAGE true
ENV APP_HOME /application
ENV RAILS_ENV production


RUN apt-get update && apt-get install -y --force-yes \
  autoconf \
  build-essential \
  cmake \
  pkg-config \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libffi-dev \
  libncurses5-dev \
  libgdbm3 \
  libgdbm-dev \
  libsqlite3-dev \
  libmysqlclient-dev \
  libv8-dev \
  mysql-client \
  netcat \
  wget && \
  gem install --no-document bundler &&\
  mkdir -p "$APP_HOME" &&\
  gem install puma

COPY files/rails_application.tar.gz "$APP_HOME"

RUN  echo "PREPARING APPLICATION" && \
      cd "$APP_HOME" &&\
      tar xzf rails_application.tar.gz && \
      bundle install --without test development
      
COPY files/database.yml "$APP_HOME/config"
    
EXPOSE 3000
COPY wait_for_port.sh /wait_for_port.sh
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
