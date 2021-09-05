FROM pytorch/pytorch:1.7.0-cuda11.0-cudnn8-runtime

ENV TZ=America/Toronto

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y wget unzip git awscli

# gcc needed for python mscoco lib
# ffmpeg for cv2
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install gcc mono-mcs ffmpeg libsm6 libxext6 && \
    rm -rf /var/lib/apt/lists/*

# Pre-built
RUN python -m pip install detectron2 -f \
  https://dl.fbaipublicfiles.com/detectron2/wheels/cu110/torch1.7/index.html

RUN git clone https://github.com/facebookresearch/slowfast.git; cd slowfast; python setup.py build develop; cd ..

RUN git clone https://github.com/patrickmineault/research_code.git; cd research_code; pip install -e .; cd ..

ADD fetch_and_run_git.sh /usr/local/bin/fetch_and_run_git.sh
WORKDIR /tmp
USER nobody
ENTRYPOINT ["/usr/local/bin/fetch_and_run_git.sh"]