FROM golang:1.25 AS build
WORKDIR /src
COPY vendor vendor/
COPY go.mod go.sum ./
COPY . .
RUN CGO_ENABLED=0 go build -mod=vendor -o /out/api ./cmd/api

FROM alpine:3.20
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /app
COPY --from=build /out/api ./api
EXPOSE 8080
ENTRYPOINT ["./api"]
