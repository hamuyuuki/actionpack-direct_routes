FROM ruby:2.4
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir /usr/local/src/actionpack-direct_routes
WORKDIR /usr/local/src/actionpack-direct_routes
