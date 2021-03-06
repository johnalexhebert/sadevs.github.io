PY?=python3
PELICAN?=pelican
PELICANOPTS=
PYTHON=python3
PIPENV_PATH?=$(shell command -v pipenv 2> /dev/null)
PIPENV?=$(PYTHON) -m pipenv
PIPENV_RUN?=$(PIPENV) run
PIP?=$(PYTHON) -m pip

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif

help:
	@echo 'Makefile for a pelican Web site                                           '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make clean                          remove the generated files         '
	@echo '   make regenerate                     regenerate files upon modification '
	@echo '   make publish                        generate using production settings '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000'
	@echo '   make serve-global [SERVER=0.0.0.0]  serve (as root) to $(SERVER):80    '
	@echo '   make devserver [PORT=8000]          start/restart develop_server.sh    '
	@echo '   make stopserver                     stop local server                  '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo 'Set the RELATIVE variable to 1 to enable relative urls                    '
	@echo '                                                                          '

pipenv:
ifeq ($(PIPENV_PATH),)
	$(PIP) install pipenv
endif

install: pipenv
	$(PIPENV) install

themes/brutalist/README.md:
	git submodule update --init

html: install themes/brutalist/README.md
	$(PIPENV_RUN) $(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate: installthemes/brutalist/README.md
	$(PIPENV_RUN) $(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	cd $(OUTPUTDIR) && $(PIPENV_RUN) $(PY) -m pelican.server $(PORT)
else
	cd $(OUTPUTDIR) && $(PIPENV_RUN) $(PY) -m pelican.server
endif

serve-global:
ifdef SERVER
	cd $(OUTPUTDIR) && $(PIPENV_RUN) $(PY) -m pelican.server 80 $(SERVER)
else
	cd $(OUTPUTDIR) && $(PIPENV_RUN) $(PY) -m pelican.server 80 0.0.0.0
endif


devserver:
ifdef PORT
	$(PIPENV_RUN) $(BASEDIR)/develop_server.sh restart $(PORT)
else
	$(PIPENV_RUN) $(BASEDIR)/develop_server.sh restart
endif

stopserver:
	$(PIPENV_RUN) $(BASEDIR)/develop_server.sh stop
	@echo 'Stopped Pelican and SimpleHTTPServer processes running in background.'

publish: install themes/brutalist/README.md
	$(PIPENV_RUN) $(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

.PHONY: install html help clean regenerate serve serve-global devserver stopserver publish
