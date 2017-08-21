# vault-cci

[![CircleCI](https://circleci.com/gh/AlexanderMann/vault-cci.svg?style=svg)](https://circleci.com/gh/AlexanderMann/vault-cci)

[Published Continuously on Dockerhub using CircleCI](https://hub.docker.com/r/mannimal/vault-cci/)

Simple vault container for use in CircleCI 2.0

***NOTE: This is not entirely recommended for use in a production environment.*** The only secure way to run vault is what's recommended by Hashicorp, which this is not. This container exists to simplify development workflows, CI testing, and to reduce code complexity for systems which wish to use a secure Vault instance, but are sometimes shipped in "demonstration" modes.

In using this container you can gain access to a client token from outside the container using `curl`:

```
curl localhost:8201/client-token
```

This allows you to do whatever initialization/testing against vault, essentially getting aroung the lack of default client tokens.

## Example usage in CCI

```
version: 2.0
jobs:
  build:
    docker:
      - image: postgres:9.6
        environment:
          POSTGRES_USER: a-user
          POSTGRES_DB: a-secret
      - image: hopsoft/graphite-statsd
      - image: mannimal/vault-cci
        environment:
          SKIP_SETCAP: skip
  steps:
    - checkout
    - run:
        name: Setup Vault
        command: curl localhost:8201/client-token
```

## Docker Compose

```
  vault:
    image: mannimal/vault-cci
    ports:
      - '8200:8200'
      - '8201:8201'
    volumes:
      - ./vault/file:/vault/file
    cap_add:
      - IPC_LOCK
```

### Restarting

*NOTE:* When you mount a volume to `/vault/file`, the container used for this can reinitialize itself.

This means that any data you encrypt using vault can be retrieved even after shutting Vault down provided you remount the previous Volume.
