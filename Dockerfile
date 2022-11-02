FROM python:3.9-alpine3.13
LABEL maintainer="demilson.fayika"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        gcc libc-dev linux-headers postgresql-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ] ; \
        then echo "--DEV BUILD--" && /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    apk del .tmp-build-deps && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user

#So online 15 we did apk add and we installed the PostgreSQL client.So this is the client package that we're going to need installed inside our Alpine image in order for our cycle G2 package to be able to connect to Postgres. So this is the dependency that needs to stay inside the Docker image when we're running it in production.
#And below that on line 16, we define a new line that said APK and is very similar to the first line, except we have this virtual option here.
#So it kind of groups the packages that we install into this name called temp build deps and we can use this to remove these packages later on inside our Docker file.

###So once we've been that we then down here on line 23, we remove the temp build deps and all this does is it removes these packages that we installed up here on line 17.