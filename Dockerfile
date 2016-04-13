FROM buildpack-deps:jessie-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.6.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 6d894da8b4ad3f7f6c295db0d73ccc3646bce630e1c43e662a0120681d47e988

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& mkdir GOCODE \
	&& cd GOCODE \
	&& mkdir {,src,bin,pkg}
	&& tar -C ~/GOCODE -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:$GOPATH/GOCODE/go/bin:$PATH

RUN chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper $GOPATH/bin/

    Status

