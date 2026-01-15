FROM golang:1.24.5

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -v -o /interview-Q1 ./main.go

CMD ["/interview-Q1"]