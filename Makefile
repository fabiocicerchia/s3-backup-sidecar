IMAGE     ?= ghcr.io/fabiocicerchia/s3-backup-sidecar
VERSION   ?= 1.0.0
PLATFORMS ?= linux/amd64,linux/arm64

# Every verb this repository exposes lives here; `make` on its own prints them.
# FC-GEN-057: the same eight verbs in every repo, each either wired or a
# declared no-op that says why. None of them exit 0 quietly.

.PHONY: help setup install build test lint run format analyze push release

.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

build: ## Build the image locally
	docker build -t $(IMAGE):$(VERSION) .

lint: ## Run the whole gate — every hook, every file
	pre-commit run --all-files

test: build ## Build, then run the smoke tests
	./test.sh $(IMAGE):$(VERSION)

setup: ## Install the pre-commit hook
	pre-commit install

install: ## Pull the published image onto this machine
	docker pull $(IMAGE):$(VERSION)

run: build ## Run the sidecar from the image (ARGS are its arguments)
	docker run --rm $(IMAGE):$(VERSION) $(ARGS)

format: ## Rewrite what the gate can fix: whitespace, line endings, final newline
	@# A fixing hook exits 1 when it rewrites a file. That is this target doing
	@# its job, not failing, so the exits are ignored — make still prints what
	@# each hook said.
	-pre-commit run --all-files trailing-whitespace
	-pre-commit run --all-files end-of-file-fixer
	-pre-commit run --all-files mixed-line-ending

analyze: ## Scan the tree the way CI does — vulnerabilities, misconfig, secrets
	@command -v trivy >/dev/null 2>&1 || { \
		echo "analyze needs trivy: https://trivy.dev/latest/getting-started/installation/" >&2; \
		exit 69; }
	trivy fs --scanners vuln,misconfig,secret --severity CRITICAL,HIGH .

push: build ## Push the tagged image
	docker push $(IMAGE):$(VERSION)

release: ## Multi-arch buildx build and push (version + latest)
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
