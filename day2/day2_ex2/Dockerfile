FROM amazonlinux:latest
RUN yum update -y && yum install -y httpd awscli
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
