FROM ubuntu:xenial as openedx

RUN apt update && \
  apt install -y git-core language-pack-en apparmor apparmor-utils python3 python3-pip python3-dev && \
  pip3 install --upgrade pip setuptools && \
  rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /edx/etc/xqueue_watcher/
RUN chmod -R a+r /edx/app/xqueue_watcher
WORKDIR /edx/app/xqueue_watcher
COPY conf.d/empty.yml /edx/etc/xqueue_watcher/config.yml

COPY . /edx/app/xqueue_watcher

RUN pip3 install -r /edx/app/xqueue_watcher/requirements/production.txt
RUN pip3 install -e /edx/app/xqueue_watcher


RUN useradd -m --shell /bin/false app
RUN chown -R app /edx/app/xqueue_watcher
RUN chown -R app /edx
RUN pip3 install -e /edx/app/xqueue_watcher

USER app
CMD python3 -m xqueue_watcher -f /edx/etc/xqueue_watcher/config.yml


FROM openedx as edx.org
RUN pip3 install newrelic
CMD newrelic-admin run-program python3 -m xqueue_watcher -f /edx/etc/xqueue_watcher/config.yml
