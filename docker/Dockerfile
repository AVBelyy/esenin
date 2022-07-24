FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y dist-upgrade

RUN apt-get install -y git
RUN apt-get install -y nodejs
RUN apt-get install -y npm

# Install nodedependencies.
RUN npm install -g coffeescript
RUN npm install

RUN git clone --depth=1 https://github.com/AVBelyy/esenin.git
WORKDIR esenin
CMD git checkout bcd591ac995f3e46f7f0cc3b89e8aef094062400

CMD coffee server.coffee
