FROM golang:1.23 AS build

WORKDIR /go/src/fiberexample

COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o app .

FROM alpine:latest AS release

ARG PORT=3000
ENV PORT=${PORT}

WORKDIR /app

COPY --from=build /go/src/fiberexample/app .

RUN apk -U upgrade && apk add --no-cache dumb-init ca-certificates && chmod +x /app/app

EXPOSE ${PORT}

ENTRYPOINT ["/usr/bin/dumb-init", "--", "./app"]
