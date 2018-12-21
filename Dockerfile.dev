FROM ruby:2.5-stretch

LABEL maintainer="Carsten Nielsen <heycarsten@gmail.com>"

ENV POSTGRES_VERSION=9.6
ENV NODE_DIST=10.x
ENV PGUSER=postgres
ENV PATH=/lcboapi/bin:$PATH
ENV HOME=/lcboapi

# Install basics
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq update && \
    apt-get -yqq install \
    software-properties-common \
    apt-transport-https \
    build-essential \
    git-core \
    openssl \
    libssl-dev \
    acl \
    zip \
    pv \
    postgresql-client-$POSTGRES_VERSION \
    libpq-dev \
    nodejs \
    yarn

RUN mkdir -p $HOME

WORKDIR $HOME

COPY Gemfile /lcboapi
COPY Gemfile.lock /lcboapi

RUN bundle install
