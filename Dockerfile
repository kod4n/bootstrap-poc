FROM amazon/aws-cli:2.0.7

WORKDIR /cratekube/bootstrap

RUN yum install -y jq openssh &&\
    curl -L -o rke_linux-amd64  https://github.com/rancher/rke/releases/download/v1.1.0/rke_linux-amd64 &&\
    mv rke_linux-amd64 /usr/local/bin/rke &&\
    chmod +x /usr/local/bin/rke

COPY bootstrap.sh .

ENTRYPOINT ["/cratekube/bootstrap/bootstrap.sh"]