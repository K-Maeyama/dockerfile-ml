# https://hub.docker.com/r/naruya/
# $ docker run --runtime=nvidia -it --privileged -p 5900:5900 naruya/dl_remote

# [1] https://github.com/robbyrussell/oh-my-zsh
# [2] https://github.com/pyenv/pyenv/wiki/common-build-problems


FROM nvidia/cudagl:11.2.1-base-ubuntu18.04       
ENV DEBIAN_FRONTEND=noninteractive

ENV HOME /root
WORKDIR /root

RUN apt-get update -y && apt-get -y upgrade

# tmux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tmux \
    vim

# pyenv,[2] ----------------
ENV PYTHON_VERSION 3.7.10
ENV PYTHON_ROOT $HOME/local/python-$PYTHON_VERSION
ENV PATH $PYTHON_ROOT/bin:$PATH
ENV PYENV_ROOT $HOME/.pyenv
RUN apt-get update && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
    git \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
 && git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT \
 && $PYENV_ROOT/plugins/python-build/install.sh \
 && /usr/local/bin/python-build -v $PYTHON_VERSION $PYTHON_ROOT \
 && rm -rf $PYENV_ROOT


# X window, options ----------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim xvfb x11vnc python-opengl
RUN pip install --upgrade pip
RUN pip install setuptools jupyterlab==2
EXPOSE 8888
EXPOSE 5900

RUN pip install ipywidgets
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

RUN echo 'Xvfb :0 -screen 0 1400x900x24 & ' >> /root/Xvfb-run.sh && \
    echo 'x11vnc -display :0 -passwd pass -forever &' >> /root/run-Xvfb.sh && \
    chmod +x /root/run-Xvfb.sh

RUN echo 'DISPLAY=:0 jupyter notebook --allow-root --ip=0.0.0.0 --port 8888 --notebook-dir=/root --NotebookApp.password="sha1:71247b1fba50:6334281a44d2134e85492be9ad7426a3cf9caf90" &' >> /root/run-jupyter.sh && \
    chmod +x /root/run-jupyter.sh

RUN pip install tensorflow && \
    echo 'alias tb="tensorboard --logdir runs --bind_all &"' >> /root/.zshrc

# install torch
# RUN pip install torch torchvision torchaudio
RUN pip install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html

RUN pip install numpy==1.19.5
RUN pip install pytest autopep8 matplotlib opencv-python pandas seaborn
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    pip install -e .
RUN apt-get update && apt-get upgrade -y \
&& apt-get install -y --no-install-recommends \
    cmake
RUN pip install 'gym[atari]'

RUN git clone https://github.com/syuntoku14/ShinRL.git ShinRL && \
   cd ShinRL && \
   pip install -e .


#RUN pip install matplotlib

# install tensorboard
# RUN pip install --upgrade pip
# RUN pip install tensorflow
# RUN pip install tensorboardX

#RUN pip install hydra-core --upgrade
#RUN pip install ray

#RUN pip install torch==1.4.0 torchvision==0.5.0

# install optuna
#RUN pip install optuna


# install gym
#RUN git clone https://github.com/openai/gym.git && \
#    cd gym && \
#    pip install -e .
#RUN pip install 'gym[atari]'

# install pybullet
#RUN git clone https://github.com/benelot/pybullet-gym.git && \
#    cd pybullet-gym && \
#    pip install -e .
#RUN pip install  pybullet==2.5.9



#RUN pip install ray box2d-py psutil setproctitle

#RUN pip install aiohttp psutil setproctitle grpcio
#RUN pip install pandas tabulate pillow==6.2.1 matplotlib



# auto start tmux and zsh
ENTRYPOINT tmux new \; \
            send-keys 'Xvfb :0 -screen 0 1400x900x24 & ' Enter \; \
	    send-keys 'x11vnc -display :0 -passwd 0123 -forever &' Enter \; \
            split-window -v  \; \
            send-keys "jupyter nbextension enable --py widgetsnbextension --sys-prefix" Enter \; \
            send-keys "bash /root/run-jupyter.sh" Enter \; \
	   new-window \; \
    	    send-keys clear C-m \;

# ENTRYPOINT Xvfb :0 -screen 0 1400x900x24 
	    #    x11vnc -display :0 -passwd 0123 -forever \
        #    jupyter nbextension enable --py widgetsnbextension --sys-prefix \
        #    bash /root/run-jupyter.sh \
    	    # send-keys clear C-m \;