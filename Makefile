.DEFAULT_GOAL = help

VERSION = 1.0.0

GO-VERSION = 1.21.5
GO-VER = go$(GO-VERSION)

SRC = $(shell find . -name "*.go" | grep -v "_test\." )

.PHONY: help
help: ## list Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: version download checkfmt checkimports vet $(SRC) ## build the provider
	goreleaser build --rm-dist --snapshot

.PHONY: clean
clean: ## clean up build artifacts
	- rm -rf cloudfoundry.org
	- rm -rf /tmp/tpcsbsqlserver-coverage.out

.PHONY: test
test: version download checkfmt checkimports vet ginkgo ## run all build, static analysis, and test steps

.PHONY: ginkgo
ginkgo: ## run the tests with Ginkgo
	## runs docker, so tricky to make it work inside docker
	go run github.com/onsi/ginkgo/v2/ginkgo -r -v

.PHONY: ginkgo-coverage
ginkgo-coverage: ## ginkgo tests coverage score
	go test -coverprofile=/tmp/tpcsbsqlserver-coverage.out ./...
	go tool cover -func /tmp/tpcsbsqlserver-coverage.out | grep total

download: ## download dependencies
	go mod download

vet: ## run static code analysis
	go vet ./...
	go run honnef.co/go/tools/cmd/staticcheck ./...

checkfmt: ## check that the code is formatted correctly
	@@if [ -n "$$(gofmt -s -e -l -d .)" ]; then \
		echo "gofmt check failed: run 'make fmt'"; \
		exit 1; \
	fi

checkimports: ## check that imports are formatted correctly
	@@if [ -n "$$(go run golang.org/x/tools/cmd/goimports -l -d .)" ]; then \
		echo "goimports check failed: run 'make fmt'";  \
		exit 1; \
	fi

fmt: ## format the code
	gofmt -s -e -l -w .
	go run golang.org/x/tools/cmd/goimports -l -w .

.PHONY: version
version:
	@@go version
	@@if [ "$$(go version | awk '{print $$3}')" != "${GO-VER}" ]; then \
		echo "Go version does not match: expected: ${GO-VER}, got $$(go version | awk '{print $$3}')"; \
		exit 1; \
	fi
