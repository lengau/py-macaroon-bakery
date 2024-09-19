# Copyright 2017,2024 Canonical Ltd.
# Licensed under the LGPLv3, see LICENCE file for details.
include sysdeps.mk

PYTHON = python

SYSDEPS_INSTALLED = .sysdeps-installed
DEVENV = venv
DEVENVPIP = $(DEVENV)/bin/pip

.DEFAULT_GOAL := setup

$(DEVENVPIP):
	@tox devenv -e devenv

$(SYSDEPS_INSTALLED): sysdeps.mk
ifeq ($(shell command -v apt-get > /dev/null; echo $$?),0)
	sudo apt-get install --yes $(APT_SYSDEPS)
else ifeq ($(shell command -v brew > /dev/null; echo $$?),0)
	brew install $(BREW_SYSDEPS)
else
	@echo 'System dependencies can only be installed automatically on'
	@echo 'systems with "apt-get" or "brew". Dependencies correspond to'
	@echo 'the following Debian packages:'
	@echo '$(APT_SYSDEPS).'
endif
	@command -v tox > /dev/null || (echo "Could not find tox on the PATH"; exit 1)
	@command -v isort > /dev/null || (echo "Could not find isort on the PATH"; exit 1)
	touch $(SYSDEPS_INSTALLED)

.PHONY: check
check: setup lint
	@tox

.PHONY: clean
clean:
	$(PYTHON) setup.py clean
	# Remove the development environments.
	rm -rf $(DEVENV) .tox/
	# Remove distribution artifacts.
	rm -rf *.egg build/ dist/ macaroonbakery.egg-info MANIFEST
	# Remove tests artifacts.
	rm -f .coverage
	# Remove the canary file.
	rm -f $(SYSDEPS_INSTALLED)
	# Remove Python compiled bytecode.
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d -delete

.PHONY: docs
docs: setup
	@tox -e docs

.PHONY: help
help:
	@echo -e 'Macaroon Bakery - list of make targets:\n'
	@echo 'make - Set up the development and testing environment.'
	@echo 'make test - Run tests.'
	@echo 'make lint - Run linter and pep8.'
	@echo 'make check - Run all the tests and lint in all supported scenarios.'
	@echo 'make source - Create source package.'
	@echo 'make wheel - Create wheel package.'
	@echo 'make clean - Get rid of bytecode files, build and dist dirs, venvs.'
	@echo 'make release - Register and upload a release on PyPI.'
	@echo -e '\nAfter creating the development environment with "make", it is'
	@echo 'also possible to do the following:'
	@echo '- run a specific subset of the test suite, e.g. with'
	@echo '  "$(DEVENV)/bin/nose2 bakery/tests/...";'
	@echo '- use tox as usual on this project;'
	@echo '  see https://tox.readthedocs.org/en/latest/'


.PHONY: lint
lint: setup
	@tox -e lint

.PHONY: release
release: check
	$(PYTHON) setup.py register sdist bdist_wheel upload

.PHONY: setup
setup: $(SYSDEPS_INSTALLED) $(DEVENVPIP) setup.py

.PHONY: source
source:
	$(PYTHON) setup.py sdist

.PHONY: wheel
wheel:
	$(PYTHON) setup.py bdist_wheel

.PHONY: sysdeps
sysdeps: $(SYSDEPS_INSTALLED)

.PHONY: test
test: setup
	@$(DEVENV)/bin/nose2 \
		--verbosity 2 --with-coverage macaroonbakery

.PHONY: isort
isort:
	isort \
		--trailing-comma \
		--recursive \
		--multi-line 3 \
		`find macaroonbakery -name '*.py' | grep -v 'internal/id_pb2\.py'`
