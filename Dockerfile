FROM ubuntu:20.04

# some...
RUN apt update
RUN apt-get install -y git
# RUN apt install -y git

# clone project
# blocked by gfw
RUN git clone https://github.com/kovidgoyal/bypy.git
RUN git clone https://github.com/kovidgoyal/calibre.git

# need ssh keys
# RUN git clone git@github.com:kovidgoyal/bypy.git
# RUN git clone git@github.com:kovidgoyal/calibre.git

# install dependances
# TODO: #5 docker build install dependances, ref: [calibre/sources.json at master · kovidgoyal/calibre]( https://github.com/kovidgoyal/calibre/blob/master/bypy/sources.json )
# 
RUN cd calibre && ./setup.py bootstrap
