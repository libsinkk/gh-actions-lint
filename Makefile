# All targets that are not files
.PHONY: all configure build open run help

# Only show the output
.SILENT: help

# The default target to run
.DEFAULT_GOAL := help

# Variables
pwdname := $(shell basename `pwd`)

# Try to detect the OS, falling back to 'uname' if $(OS) is empty
ifndef $(OS)
	OS := $(shell uname -s)
endif

doc := README.org
basedoc := dist/doc/README
MAKEINFO ?= makeinfo


help:             ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m      %s\n", $$1, $$2}'

dist:             ## create a distribution tar file for this program
	git bundle create $(pwdname).bundle HEAD
	git archive --output=$(pwdname).zip HEAD
	git archive --output=$(pwdname).tar.gz HEAD
	git archive --output=$(pwdname).tar.xz HEAD

distclean: $(pwdname).bundle $(pwdname).zip $(pwdname).tar.gz $(pwdname).tar.xz  ## like clean but do not clean installdirs and parent dirs
	$(RM) $^
	$(RM) -r dist

configure:        ## configure the build environment
	command -v go
	command -v git
	command -v makeinfo
	command -v pandoc
	git config core.hooksPath .githooks
	mkdir -p dist/doc

build:            ## generate the build
	go build
install:          ## install builds packages to
	go mod tidy
clean:            ## delete all files that are normally created by running 'make all'.
	$(RM) gh-actions-lint
html:$(basedoc).html             ## generate html documentation
$(basedoc).html: $(doc)
	pandoc -f org -t html5 --standalone -o $@ $<

pdf:$(basedoc).pdf          ## generate pdf documentation
$(basedoc).pdf: $(doc)
	pandoc -f org -o $@ $< --pdf-engine=pdflatex

$(basedoc).texi: $(doc)
	pandoc -f org -t texinfo --standalone -o $@ $<

info:$(basedoc).info             ## generate info documentation
$(basedoc).info: $(basedoc).texi
	$(MAKEINFO) --no-split $< -o $@

check:            ## run self-tests
	go test
dependencies:     ## install the dependencies
	go mod tidy
