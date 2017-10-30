# Generated by Medikit 0.4a7 on 2017-10-30.
# All changes will be overriden.

PACKAGE ?= medikit
PYTHON ?= $(shell which python)
PYTHON_BASENAME ?= $(shell basename $(PYTHON))
PYTHON_DIRNAME ?= $(shell dirname $(PYTHON))
PYTHON_REQUIREMENTS_FILE ?= requirements.txt
PYTHON_REQUIREMENTS_DEV_FILE ?= requirements-dev.txt
QUICK ?= 
PIP ?= $(PYTHON_DIRNAME)/pip
PIP_INSTALL_OPTIONS ?= 
PYTEST ?= $(PYTHON_DIRNAME)/pytest
PYTEST_OPTIONS ?= --capture=no --cov=$(PACKAGE) --cov-report html
SPHINX_BUILD ?= $(PYTHON_DIRNAME)/sphinx-build
SPHINX_OPTIONS ?= 
SPHINX_SOURCEDIR ?= docs
SPHINX_BUILDDIR ?= $(SPHINX_SOURCEDIR)/_build
YAPF ?= $(PYTHON) -m yapf
YAPF_OPTIONS ?= -rip
VERSION ?= $(shell git describe 2>/dev/null || echo dev)

.PHONY: $(SPHINX_SOURCEDIR) clean format install install-dev test update update-requirements

# Installs the local project dependencies.
install:
	if [ -z "$(QUICK)" ]; then \
	    $(PIP) install -U pip wheel $(PIP_INSTALL_OPTIONS) -r $(PYTHON_REQUIREMENTS_FILE) ; \
	fi

# Installs the local project dependencies, including development-only libraries.
install-dev:
	if [ -z "$(QUICK)" ]; then \
	    $(PIP) install -U pip wheel $(PIP_INSTALL_OPTIONS) -r $(PYTHON_REQUIREMENTS_DEV_FILE) ; \
	fi

# Cleans up the local mess.
clean:
	rm -rf build dist *.egg-info

# Update project artifacts using medikit, after installing it eventually.
update:
	python -c 'import medikit; print(medikit.__version__)' || pip install medikit;
	$(PYTHON) -m medikit update

# Remove requirements files and update project artifacts using medikit, after installing it eventually.
update-requirements:
	rm -rf requirements*.txt
	$(MAKE) update

test: install-dev
	$(PYTEST) $(PYTEST_OPTIONS) tests

$(SPHINX_SOURCEDIR): install-dev
	$(SPHINX_BUILD) -b html -D latex_paper_size=a4 $(SPHINX_OPTIONS) $(SPHINX_SOURCEDIR) $(SPHINX_BUILDDIR)/html

format: install-dev
	$(YAPF) $(YAPF_OPTIONS) .
	$(YAPF) $(YAPF_OPTIONS) Projectfile
