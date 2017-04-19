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

RUN mkdir -p /usr/local/distributed-tensorflow && \
    cd /usr/local/distributed-tensorflow && \
    git clone https://github.com/tensorflow/models.git
    
RUN echo ". /opt/DL/tensorflow/bin/tensorflow-activate" >> /etc/skel/.bashrc

COPY ./tutorials /usr/local/distributed-tensorflow/tutorials

COPY ./NAE/AppDef.json /etc/NAE/AppDef.json

# Set the URL to the Tensorboard portal
COPY ./NAE/url.txt /etc/NAE/url.txt
