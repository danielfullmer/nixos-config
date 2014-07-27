FROM ubuntu:14.04
MAINTAINER Daniel Fullmer

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y curl
RUN curl -sL https://get.docker.io/ | sh

# Terminal
RUN apt-get install -y git vim-nox tmux zsh silversearcher-ag

# Python
RUN apt-get install -y python-dev python-pip

# Scientific stuff
RUN apt-get install -y libblas-dev liblapack-dev
RUN pip install numpy
RUN pip install pandas
RUN apt-get install -y gfortran

RUN pip install scipy
RUN pip install theano

RUN apt-get install -y libzmq3-dev libevent-dev
RUN pip install ipython[notebook]
RUN pip install mpld3 vincent

RUN pip install sympy

# Academic
RUN apt-get install -y texlive pandoc pandoc-citeproc

# Clean up a little
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN sed -Ei 's/adm:x:4:/admin:x:4:admin/' /etc/group
RUN sed -Ei 's/(\%admin ALL=\(ALL\) )ALL/\1 NOPASSWD:ALL/' /etc/sudoers

# Default password: admin
RUN useradd -s /bin/zsh danielrf -G sudo,admin,docker -p sa1aY64JOY94w
RUN git clone --separate-git-dir /home/danielrf/.dotfiles --recursive https://github.com/danielfullmer/dotfiles.git /home/danielrf && rm /home/danielrf/.git
RUN chown -R danielrf:danielrf /home/danielrf

USER danielrf
WORKDIR /home/danielrf

ENV HOME /home/danielrf
ENV SHELL /bin/zsh
ENV TERM xterm-256color

RUN GIT_DIR=/home/danielrf/.dotfiles git submodule init
RUN GIT_DIR=/home/danielrf/.dotfiles git submodule update --recursive
RUN .vim/bundle/neobundle.vim/bin/neoinstall

CMD ["zsh", "--login"]
