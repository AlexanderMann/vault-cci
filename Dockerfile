FROM vault:0.7.3

ADD ./vault/ /vault
WORKDIR /vault

ENV VAULT_ADDR=http://127.0.0.1:8200
ENV SKIP_SETCAP=skip

ENTRYPOINT ["./docker-entrypoint.sh"]

