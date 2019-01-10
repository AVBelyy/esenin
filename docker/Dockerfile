FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y dist-upgrade

RUN apt-get install -y git
RUN apt-get install -y nodejs
RUN apt-get install -y npm

RUN git clone --depth=1 https://github.com/AVBelyy/esenin.git
WORKDIR esenin

# Install nodedependencies.
RUN npm install -g coffeescript
RUN npm install

CMD coffee server.coffee
