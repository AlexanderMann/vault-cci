FROM vault:0.7.3

RUN apk add --update python

ADD ./vault/ /vault
WORKDIR /vault

ENV VAULT_ADDR=http://127.0.0.1:8200

EXPOSE 8201

ENTRYPOINT ["./docker-entrypoint.sh"]
