PROJECT  ?= ruby
REGISTRY ?= abevoelker

all:
	@echo "Available targets:"
	@echo "  * build - build a Docker image for $(PROJECT)"
	@echo "  * pull  - pull down previous docker builds of $(REGISTRY)/$(PROJECT)"

build: Dockerfile
	docker build -t $(REGISTRY)/$(PROJECT) .

pull:
	docker pull $(REGISTRY)/$(PROJECT) || true
