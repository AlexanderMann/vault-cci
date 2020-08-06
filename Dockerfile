FROM vault:1.5.0

RUN apk add --update python sqlite

ADD ./vault/ /vault
WORKDIR /vault

ENV VAULT_ADDR=http://127.0.0.1:8200

EXPOSE 8201

ENTRYPOINT ["./docker-entrypoint.sh"]
