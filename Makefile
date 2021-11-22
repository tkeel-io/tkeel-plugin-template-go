GOPATH:=$(shell go env GOPATH)
VERSION=$(shell git describe --tags --always)
INTERNAL_PROTO_FILES=$(shell find internal -name *.proto)
API_PROTO_FILES=$(shell find api -name *.proto)

.PHONY: init
# init env
init:
	go install  github.com/tkeel-io/tkeel-interface/tool/cmd/artisan
	go install  github.com/tkeel-io/tkeel-interface/openapi
	go install  github.com/tkeel-io/kit
	go install  google.golang.org/protobuf/cmd/protoc-gen-go
	go install  google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install  github.com/tkeel-io/tkeel-interface/protoc-gen-go-http
	go install  github.com/tkeel-io/tkeel-interface/protoc-gen-go-errors
	go install  github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2

.PHONY: api
# generate api proto
api:
	protoc --proto_path=. \
	       --proto_path=./third_party \
 	       --go_out=paths=source_relative:. \
 	       --go-http_out=paths=source_relative:. \
 	       --go-grpc_out=paths=source_relative:. \
 	       --go-errors_out=paths=source_relative:. \
 	       --openapiv2_out . \
 	       --openapiv2_opt logtostderr=true \
 	       --openapiv2_opt json_names_for_fields=false \
	       $(API_PROTO_FILES)

.PHONY: build
# build
build:
	mkdir -p bin/ && go build -ldflags "-X main.Version=$(VERSION)" -o ./bin/ ./...

.PHONY: generate
# generate
generate:
	go generate ./...


.PHONY: all
# generate all
all:
	make api;
	make generate;

# show help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
