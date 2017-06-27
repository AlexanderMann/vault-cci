#!/bin/sh
set -ex

python_http_server() {
  # we want to be able to server the VAULT_TOKEN for testing
  cd $HOME/
  python -m SimpleHTTPServer 8201
}

vault_server () {
  vault server -dev
}

vault_server & python_http_server

