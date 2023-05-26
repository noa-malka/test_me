# Debian Buster slim is an official small image suitable for most python services.
# For more information and other options read - https://pythonspeed.com/articles/base-image-python-docker-images/
FROM python:3.9.6-slim-buster

# Install tools
# supervisor is client/server system that allows its users to monitor and control a number of linux processes
RUN set -ex \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		vim \
		nano \
		procps \
		build-essential \
		python3-dev \
		iputils-ping

# specify the service root path
ARG LINUX_DIR=/usr/bin

# copy microservice code
COPY {{plugin_name}}/{{dev_dir_name}} $LINUX_DIR/{{plugin_name}}/{{dev_dir_name}}
COPY common/{{dev_dir_name}}/src/stratos $LINUX_DIR/{{plugin_name}}/stratos

# install packages
RUN pip install --no-cache-dir -r $LINUX_DIR/{{plugin_name}}/{{dev_dir_name}}/requirements.txt

# set PYTHONPATH
ENV PYTHONPATH=$LINUX_DIR/{{plugin_name}}

# set uwsgi
# uwsgi is the fastest application server for python - https://blog.kgriffs.com/2012/12/18/uwsgi-vs-gunicorn-vs-node-benchmarks.html
RUN pip install --no-cache-dir uwsgi
COPY {{plugin_name}}/{{docker_common_dir}}/uwsgi.ini $LINUX_DIR/{{plugin_name}}/{{dev_ops_dir_name}}/uwsgi.ini

# set supervisor
RUN pip install --no-cache-dir supervisor
COPY {{plugin_name}}/{{docker_common_dir}}/supervisord.conf /etc/supervisor/supervisord.conf

#RUN python -m unittest discover --start-directory crawler/tests/se_controller
CMD supervisord
