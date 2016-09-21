FROM ubuntu:12.04

RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install build-essential
RUN apt-get -y install wget unzip
RUN apt-get -y install zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libxml2-dev libxslt-dev

WORKDIR /tmp
RUN wget http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.zip
RUN unzip ruby-2.0.0-p247.zip

WORKDIR /tmp/ruby-2.0.0-p247
RUN ./configure --prefix=/opt/rubies/ruby-2.0.0-p247
RUN make
RUN make install

WORKDIR /opt/rubies/ruby-2.0.0-p247/bin
RUN ./gem install bundler --no-rdoc --no-ri

ADD talks-app /opt/talks-app

ENV PATH /opt/rubies/ruby-2.0.0-p247/bin:$PATH

WORKDIR /opt/talks-app
RUN bundle install --path vendor/bundle

EXPOSE 327689292
ENTRYPOINT bundle exec rackup -o 0.0.0.0

