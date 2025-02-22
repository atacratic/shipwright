vault_version=1.7.0
ucm_version=31
build_number=${DRONE_BUILD_NUMBER}
build_number := $(if $(build_number),$(build_number),latest)
REPO:=registry.digitalocean.com/unison-lang

export build_number
export vault_version
export REPO

.PHONY: help build push all

help:
		@echo "Usage:"
		@echo "make build vault_version=1.7.0"
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "vault_version"
	    @echo "build_number -- as version when tagging images, defaults to DRONE_BUILD_NUMBER"
	    @echo ""
	    @echo "Makefile commands:"
	    @echo "build"
	    @echo "push"
	    @echo "all"

.DEFAULT_GOAL := all

build-%: TARGET=$(@:build-%=%)
build-%: TAG=${REPO}/${TARGET}:${build_number}	
build-%:
	docker build --no-cache \
                 --build-arg VAULT_VERSION=${vault_version} \
                 --build-arg UCM_VERSION=${ucm_version}     \
				 --target ${TARGET}                           \
				 --tag ${TAG}                                 \
                 . 

push-%: TARGET=$(@:push-%=%)
push-%: TAG=${REPO}/${TARGET}:${build_number}	
push-%:
	docker push ${TAG}

build:
	$(MAKE) build-docker-builder
	$(MAKE) build-ucm-codebase-server
	$(MAKE) build-haskell-builder

push:
	$(MAKE) push-docker-builder
	$(MAKE) push-ucm-codebase-server
	$(MAKE) push-haskell-builder


all: build push
