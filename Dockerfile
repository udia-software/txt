FROM ubuntu:18.04

ENV REFRESHED_AT=2019-09-23 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    HOME=/opt/build
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/build

RUN apt-get update -y
RUN apt-get install -y tzdata
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN apt-get install -y git wget vim gnupg
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i erlang-solutions_1.0_all.deb
RUN rm erlang-solutions_1.0_all.deb
RUN apt-get update -y
RUN apt-get install -y erlang
RUN apt-get install -y elixir

CMD ["/bin/bash"]
