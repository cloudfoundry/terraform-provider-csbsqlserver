.DEFAULT_GOAL = help

VERSION = 1.0.0

SRC = $(shell find . -name "*.go" | grep -v "_test\." )

.PHONY: help
help: ## list Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: download checkfmt checkimports vet $(SRC) ## build the provider
	goreleaser build --rm-dist --snapshot

.PHONY: clean
clean: ## clean up build artifacts
	- rm -rf cloudfoundry.org
	- rm -rf /tmp/tpcsbsqlserver-coverage.out

.PHONY: test
test: download checkfmt checkimports vet ginkgo ## run all build, static analysis, and test steps

.PHONY: ginkgo
ginkgo: ## run the tests with Ginkgo
	## runs docker, so tricky to make it work inside docker
	go tool ginkgo -r -v

.PHONY: ginkgo-coverage
ginkgo-coverage: ## ginkgo tests coverage score
	go test -coverprofile=/tmp/tpcsbsqlserver-coverage.out ./...
	go tool cover -func /tmp/tpcsbsqlserver-coverage.out | grep total

download: ## download dependencies
	go mod download

vet: ## run static code analysis
	go vet ./...
	go tool staticcheck ./...

checkfmt: ## check that the code is formatted correctly
	@@if [ -n "$$(gofmt -s -e -l -d .)" ]; then \
		echo "gofmt check failed: run 'make fmt'"; \
		exit 1; \
	fi

checkimports: ## check that imports are formatted correctly
	@@if [ -n "$$(go tool goimports -l -d .)" ]; then \
		echo "goimports check failed: run 'make fmt'";  \
		exit 1; \
	fi

fmt: ## format the code
	gofmt -s -e -l -w .
	go tool goimports -l -w .
