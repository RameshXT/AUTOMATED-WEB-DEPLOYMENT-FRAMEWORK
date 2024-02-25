FROM ubuntu:latest

RUN sudo apt-get update && \
    sudo apt-get install apache2 -y && \
    sudo systemctl start apache2 && \
    sudo systemctl start apache2

WORKDIR /var/www/html

COPY . .

EXPOSE 80