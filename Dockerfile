FROM kalilinux/kali-linux-docker 
MAINTAINER xn0px90@gmail.com
RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive RUN apt-get -y update && apt-get -y dist-upgrade && apt-get clean

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# create code directory
RUN mkdir -p /opt/code/
# install packages required to compile vala and radare2
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common python-all-dev wget
RUN apt-get install -y swig flex bison git gcc g++ make pkg-config glib-2.0
RUN apt-get install -y python-gobject-dev valgrind gdb

ENV VALA_TAR vala-0.26.1

# compile vala
RUN cd /opt/code && \
	wget -c https://download.gnome.org/sources/vala/0.26/${VALA_TAR}.tar.xz && \
	shasum ${VALA_TAR}.tar.xz | grep -q 0839891fa02ed2c96f0fa704ecff492ff9a9cd24 && \
	tar -Jxf ${VALA_TAR}.tar.xz
RUN cd /opt/code/${VALA_TAR}; ./configure --prefix=/usr ; make && make install
# compile radare and bindings
RUN cd /opt/code; git clone https://github.com/radare/radare2.git; cd radare2; ./sys/all.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN r2 -V

CMD ["/bin/bash"]
