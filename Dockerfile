FROM python:3.9-alpine3.13
#LABLE: this is the maintatiner of the IMAGE once its brought down from dockerhub 
LABEL maintainer="londonappdeveloper.com" 

#PYTHONUNBUFFERED : this is set so that there is no delay and the output of the project is brought straight to the stdoutput 
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
#WORKDIR where to run the commands what we supply on the container 
WORKDIR /app
#EXPOSE meaning expose docker 8000 to the machine on which the conatiner is running 
EXPOSE 8000


ARG DEV=false
#RUN: this will run the command on the container 
#we can breakdown the command into multiple seperate run but we have not done that because wth every RUN command docker will create a IMAGE history of the conatiner 
#and thus make our image heavy. so to keep the image light weight we combine the into one RUN block using && \
#look at video "15. Create Docker File for project" from "Build a Backend REST API with Python and Django Ad"
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/scripts:/py/bin:$PATH"

USER django-user