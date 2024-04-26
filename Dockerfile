# set arguments for the dockerfile
ARG PYTHON_VERSION=3.12

# use an official Python runtime as a parent image as interpreter
FROM python:${PYTHON_VERSION}-alpine AS base
RUN apk update && apk add git

# create a mount point for the volume
VOLUME /app/data

# set the working directory in the container
WORKDIR /app

# run command if interpreter is installed on windows machine
COPY . .

# install dependencies
RUN apk add gcc python3-dev musl-dev linux-headers

# load virtual environment
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# install packages
RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt


# run the tests
ENV GH_TOKEN ${GH_TOKEN}
ENV ENV "TEST"

RUN python get_started.py


FROM base as tests
ENV PYTHONPATH "${PYTHONPATH}:/app"
ENV ENV_ROOT_DIRECTORY "/app"
WORKDIR /app
CMD ["pytest"]


FROM base as behave
ENV PYTHONPATH "${PYTHONPATH}:/app:/app/demo"
ENV ENV_ROOT_DIRECTORY "/app"
WORKDIR /app/demo/testing/example_features_webdriver
CMD ["behave"]
