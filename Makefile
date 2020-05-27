PATH := $(PWD)/.venv/bin:$(shell printenv PATH)
PYTHONEXE:=$(shell which python3)
SHELL := env PATH=$(PATH) /bin/bash
VENV_DIR=.venv

.PHONY: clean
## Destroy docker instances, remove virtualenv, molecule temp, .pyc files
clean:
	rm -rf .venv

.PHONY: deps
## Create virtualenv, install dependencies
deps:
	test -d ${VENV_DIR} || ${PYTHONEXE} -m virtualenv --always-copy -p $(PYTHONEXE) ${VENV_DIR}
	${VENV_DIR}/bin/pip install -r requirements/main.txt
	python setup.py install

.PHONY: help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); \
		 printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

.PHONY: test
## Run tests
test: deps
	flake8 newrelic_api
	python setup.py nosetests
