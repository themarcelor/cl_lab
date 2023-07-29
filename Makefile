LISP ?= sbcl

BUILDDIR=bin
BINARYNAME=dachshund

DOCKER=docker
DOCKER-COMPOSE=docker-compose

all: build prune run

build:
	$(DOCKER) build -t ciel-build --output=. --target=binaries .

run: prune
	$(DOCKER-COMPOSE) -f docker-compose-local-run.yml up --build --abort-on-container-exit
  
prune:
	$(DOCKER) volume prune -f
	$(DOCKER) system prune -f

clean:
	rm -rf $(BUILDDIR)
