FROM ubuntu:bionic

RUN apt-get update && apt-get install -y sudo subversion maven default-jre default-jdk wget
COPY build.sh build.sh
CMD chmod +x build.sh && ./build.sh
