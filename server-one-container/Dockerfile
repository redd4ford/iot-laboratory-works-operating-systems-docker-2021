FROM ubuntu:bionic

RUN apt-get update && apt-get install -y sudo systemd dialog apt-utils curl git maven default-jre default-jdk
COPY build.sh build.sh
CMD chmod +x build.sh && ./build.sh
