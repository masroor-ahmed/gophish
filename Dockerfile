# Minify client-side assets (JavaScript)
FROM node:latest AS build-js

RUN npm install gulp gulp-cli -g

WORKDIR /build
COPY . .
RUN npm install --only=dev
RUN gulp

# Build Golang binary
FROM golang:1.15.2 AS build-golang

WORKDIR /go/src/github.com/gophish/gophish
COPY . .
RUN go get -v && go build -v

# Runtime container
FROM debian:stable-slim

RUN useradd -m -d /opt/gophish -s /bin/bash app

RUN apt-get update && \
    apt-get install --no-install-recommends -y jq libcap2-bin ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/gophish
COPY --from=build-golang /go/src/github.com/gophish/gophish/ ./
COPY --from=build-js /build/static/js/dist/ ./static/js/dist/
COPY --from=build-js /build/static/css/dist/ ./static/css/dist/
COPY --from=build-golang /go/src/github.com/gophish/gophish/config.json ./
COPY ./run.sh ./docker/

RUN chown app. config.json
RUN chmod +x ./docker/run.sh

RUN setcap 'cap_net_bind_service=+ep' /opt/gophish/gophish

USER app

EXPOSE $PORT

CMD ["./docker/run.sh"]
