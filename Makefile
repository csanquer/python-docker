# set default shell
SHELL := $(shell which bash)
GROUP_ID = $(shell id -g)
USER_ID = $(shell id -u)
GROUPNAME =  dev
USERNAME = dev
HOMEDIR = /home/$(USERNAME)

ENV = /usr/bin/env
DKC = docker-compose
DK = docker
# default shell options
.SHELLFLAGS = -c

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
default: all;   # default target

.PHONY: all volumes dkc-env dkc-build dk-stop dk-rm _dk-rm dk-prune _upd

volumes:
	mkdir -p volumes/apps

dkc-env: volumes
	cp -n .env.dist .env

# unit tests with docker
dk-build: dkc-env
	$(ENV) $(DKC) build

dk-stop: dkc-env
	$(ENV) $(DKC) stop

dk-rm: dk-stop
dk-rm: _dk-rm

_dk-rm: dkc-env
	$(ENV) $(DKC) rm -f -v

dk-prune: dkc-env
	$(ENV) $(DKC) down -v --remove-orphans

dk-up: dkc-env
dk-up: _dk-upd
dk-up: dk-ps

_dk-upd: dkc-env
	$(ENV) $(DKC) up -d --remove-orphans

dk-ps: dkc-env
	$(ENV) $(DKC) ps
