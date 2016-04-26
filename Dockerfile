FROM kalilinux/kali-linux-docker
#FROM buildpack-deps:wheezy-scm
MAINTAINER xn0px90@gmail.com
RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive RUN apt-get -y update && apt-get -y dist-upgrade && apt-get clean

# gcc for cgo
RUN apt-get update && apt-get install -y \
		curl \
		openssl \
		g++ \
		gcc \
		libc6-dev \
		make \
		software-properties-common \
		python-all-dev \
		wget \
 		swig \ 
 		flex \ 
 		bison \ 
 		git \ 
 		pkg-config \
 		glib-2.0 \
		python-gobject-dev \ 
		valgrind \ 
		gdb \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.6.2
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 e40c36ae71756198478624ed1bb4ce17597b3c19d243f3f0899bb5740d56212a

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/


# Set correct environment variables.
ENV HOME /root
# create code directory
RUN mkdir -p /opt/code/
# install packages required to compile vala and radare2
RUN apt-get update
RUN apt-get upgrade -y

ENV VALA_TAR vala-0.26.1

# compile vala
RUN cd /opt/code && \
	wget -c https://download.gnome.org/sources/vala/0.26/${VALA_TAR}.tar.xz && \
	shasum ${VALA_TAR}.tar.xz | grep -q 0839891fa02ed2c96f0fa704ecff492ff9a9cd24 && \
	tar -Jxf ${VALA_TAR}.tar.xz
RUN cd /opt/code/${VALA_TAR}; ./configure --prefix=/usr ; make && make install
# compile radare and bindings
#RUN cd /opt/code; git clone https://github.com/radare/radare2.git; cd radare2; ./sys/all.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN r2 -V

CMD ["/bin/bash"]
