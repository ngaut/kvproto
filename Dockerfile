# Build as: docker build -t tikv/protoc:3.8.0 .
FROM golang:1.15.7
ENV PROTOBUF_VERSION 3.8.0

RUN mkdir /kvproto
WORKDIR /kvproto

# Install protoc
ENV PB_REL="https://github.com/protocolbuffers/protobuf/releases"
RUN apt-get update && apt-get -y install curl unzip
RUN curl -LO ${PB_REL}/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip \
 && unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip -d protoc \
 && chmod +x protoc/bin/* \
 && mv protoc/bin/* /usr/bin/ \
 && rm protoc-${PROTOBUF_VERSION}-linux-x86_64.zip  \
 && rm -r protoc

CMD ["/usr/bin/protoc"]

# Rust build deps
# RUN apt-get install -y cmake
RUN apt install -y cmake clang libclang-dev llvm llvm-dev

RUN useradd -ms /bin/sh kvproto
USER kvproto
WORKDIR /home/kvproto

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=/home/kvproto/.cargo/bin:$PATH

#RUN mkdir -p /home/kvproto/tikv/kvproto
#WORKDIR /home/kvproto/tikv/kvproto/
#ADD --chown=kvproto:kvproto go.mod go.sum ./
#RUN go mod download
# TODO: Lock this down to specific versions
# Install gogo, an optimised fork of the Golang generators
#RUN go get github.com/gogo/protobuf/proto \
#       github.com/gogo/protobuf/protoc-gen-gogo \
#       github.com/gogo/protobuf/gogoproto \
#       github.com/gogo/protobuf/protoc-gen-gogofast \
#       github.com/gogo/protobuf/protoc-gen-gogofaster \
#       github.com/gogo/protobuf/protoc-gen-gogoslick

#ADD Cargo.toml Cargo.lock build.rs  ./
#RUN mkdir -p ./src
#RUN touch ./src/lib.rs
#RUN cargo check && cargo check --no-default-features --features prost-codec

# GOPATH stuff is messed up, maybe you know how to fix it?
#RUN rmdir /go/src && ln -s /usr/local/go/src /go/src
#	:wRUN ln -s /go/pkg/mod/github.com/google /go/src/google
# ln -s /go/pkg/mod/github.com/gogo/protobuf@v1.3.1/protobuf/google/protobuf /go/src/google/protobuf
#ADD tools.json
#RUN echo "install tools..." \
# && GO111MODULE=off go get github.com/twitchtv/retool \
# && GO111MODULE=off retool sync
