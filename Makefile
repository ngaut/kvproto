### Makefile for kvproto

CURDIR := $(shell pwd)

export PATH := $(CURDIR)/bin/:$(PATH)

all: go rust c++

init:
	mkdir -p $(CURDIR)/bin
check: init
	$(CURDIR)/scripts/check.sh
go: check
	# Standalone GOPATH
	$(CURDIR)/scripts/generate_go.sh
	GO111MODULE=on go mod tidy
	GO111MODULE=on go build ./pkg/...

rust: init
	cargo check
	cargo check --no-default-features --features prost-codec

c++: check
	$(CURDIR)/scripts/generate_cpp.sh
	rm -rf build_cpp && mkdir build_cpp && cd build_cpp && cmake ../cpp && make && cd .. && rm -rf build_cpp

docker: docker-build
	docker run -e SHELL_DEBuG=1 --rm -i -t -v $(CURDIR):/home/kvproto/go/src/github.com/pingcap/kvproto -w /home/kvproto/go/src/github.com/pingcap/kvproto tikv/protoc:3.8.0 make
	#docker run --rm -i -t -v $(CURDIR):/go/src/github.com/pingcap/kvproto -w /go/src/github.com/pingcap/kvproto tikv/protoc:3.8.0 make


docker-build:
	docker build -t tikv/protoc:3.8.0 .

.PHONY: all docker
