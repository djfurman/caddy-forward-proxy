FROM golang:1 as BUILDER

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOARCH=arm64
ENV GOOS=linux

WORKDIR /app
ADD . /app
RUN go build -o /app/forward-proxy

FROM --platform=arm64 scratch as BASE

COPY --from=BUILDER /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=BUILDER /usr/share/zoneinfo/Etc/UTC /etc/localtime
COPY --from=BUILDER /app/forward-proxy /opt/forward-proxy

ADD ./Caddyfile /opt/Caddyfile

EXPOSE 2015 2019

ENTRYPOINT [ "/opt/forward-proxy", "run" ]
