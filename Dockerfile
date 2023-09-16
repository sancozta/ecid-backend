FROM ubuntu:22.04

WORKDIR /tmp 

ADD ./install-ecidade-ubuntu-22-04-postgresql-10.sh ./

COPY ./install-ecidade-ubuntu-22-04-postgresql-10.sh /tmp

EXPOSE 80

RUN ls -la

RUN echo "FIM"