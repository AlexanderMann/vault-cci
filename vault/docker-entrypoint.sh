#!/bin/sh
set -ex

mkdir -p /vault/__restricted;

status() {
  vault status 2>&1
}

wait() {
  NUM_TRIES=0
  while [[ $NUM_TRIES -lt 5 ]]; do
    if status | grep -v 'connection refused'; then
      let NUM_TRIES=5
      echo vault ready;
    else
      let NUM_TRIES+=1
      sleep 2
    fi
  done

  if status | grep 'connection refused'; then
    exit 27
  fi
}

setup_token() {
  root_token=`grep 'Root' /vault/file/vault-init-out | sed 's/^.*: //g'`

  vault login $root_token;

  # period of 100 days
  vault token create -period="768h" > /vault/file/client-token;
  grep -e 'token ' /vault/file/client-token | sed 's/^token\W*//g' > /vault/__restricted/client-token;
}

unseal() {
  keys=`head -n 3 /vault/file/vault-init-out | sed 's/^.*: //g'`

  for k in $keys; do
    vault operator unseal $k;
  done;

  setup_token;
}

bootstrap() {
  vault operator init > /vault/file/vault-init-out 2>&1

  unseal;

  vault secrets enable transit
}

child_process () {
  wait;
  if [ -s /vault/file/vault-init-out ]; then
    unseal;
  else
    bootstrap;
  fi

  status;
}

vault_server() {
  if [[ "skip" = "$SKIP_SETCAP" ]]; then
    sed -i 's/false/true/g' /vault/config/vault.json;
  fi;
  vault server -config=/vault/config/;
}

python_http_server() {
  # we want to be able to serve the VAULT_TOKEN for testing
  cd /vault/__restricted;
  python -m SimpleHTTPServer 8201;
}

child_process & vault_server & python_http_server
