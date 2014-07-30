FROM ubuntu:14.04
MAINTAINER Daniel Fullmer

ENV DEBIAN_FRONTEND noninteractive

# Terminal
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential rsync \
    curl wget man-db git \
    openssh-client htop procps tree \
    zsh fish \
    tmux vim-nox silversearcher-ag \
    texlive pandoc pandoc-citeproc \
    python-dev python-pip \
    libblas-dev liblapack-dev \
    gfortran \
    libzmq3-dev libevent-dev && \
    locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Docker
RUN curl -sL https://get.docker.io/ | sh

# Scientific python
RUN pip install numpy pandas scipy theano ipython[notebook] mpld3 vincent sympy

# Clean up a little
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up admin group / sudo
RUN sed -Ei 's/adm:x:4:/admin:x:4:admin/' /etc/group && sed -Ei 's/(\%admin ALL=\(ALL\) )ALL/\1 NOPASSWD:ALL/' /etc/sudoers

# Default password: admin
RUN useradd -s /bin/zsh danielrf -G sudo,admin,docker -p sa1aY64JOY94w

ADD . /home/danielrf/
RUN chown -R danielrf:danielrf /home/danielrf

USER danielrf
WORKDIR /home/danielrf

ENV HOME /home/danielrf
ENV LC_ALL en_US.UTF-8
ENV USER danielrf
ENV SHELL /bin/zsh
ENV TERM xterm-256color

RUN .vim/bundle/neobundle.vim/bin/neoinstall

CMD ["zsh", "--login"]
