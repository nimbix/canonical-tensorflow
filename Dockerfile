FROM jarvice/ubuntu-ibm-mldl-ppc64le

RUN . /opt/DL/tensorflow/bin/tensorflow-activate && \
    pip install --upgrade six pandas

RUN apt-get update && \
    apt-get install -y \
            emacs \
            htop \
            git \
            telnet \
            tmux \
    && apt-get clean

# Automatically add tensorflow into environment
RUN echo ". /opt/DL/tensorflow/bin/tensorflow-activate" >> /etc/skel/.bashrc

COPY ./scripts /usr/local/distributed-tensorflow/scripts
COPY ./tools /usr/local/distributed-tensorflow/tools

# Set the URL to the Tensorboard portal
COPY ./NAE/url.txt /etc/NAE/url.txt
COPY ./NAE/AppDef.json /etc/NAE/AppDef.json
