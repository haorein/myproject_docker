# Setting up a python 3.9 environment
FROM python:3.9

# install netcat
RUN apt-get update && apt install -y netcat

# Setting python environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create the /myproject folder in the container as WORKDIR
ENV APP_HOME=/var/www/html/myproject
WORKDIR $APP_HOME

# Adding the current directory to the WORKDIR
ADD . $APP_HOME

# Update pip
RUN /usr/local/bin/python -m pip install --upgrade pip

# Install requirements
RUN pip install -r requirements.txt

# Give start.sh executable permissions
RUN chmod +x ./start.sh

# Excute start.sh to start django
ENTRYPOINT /bin/bash ./start.sh