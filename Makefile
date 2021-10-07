# Choose kubectl version from commit sha related tag
# if no tag comes out, it will use "stable" binary
KUBECTL_VERSION ?= $$(git describe --abbrev=0 --tags || curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

# Extract CPU architecture 
TARGETARCH ?= $(shell case "$$(uname -m)" in (x86_64) echo "amd64";; \
											 (aarch64) echo "arm64";; \
											 (armhf|armv7*) echo "arm";; \
											 esac;)

# Supported platforms for multiarch docker image
PLATFORMS ?= linux/amd64,linux/arm64,linux/arm

# Build the docker image
docker-build:
	docker build . -t ${IMG} --build-arg KUBECTL_VERSION=${KUBECTL_VERSION} \
										   --build-arg TARGETARCH=${TARGETARCH}

# Push the docker image
docker-push:
	docker push ${IMG}

# Build multiarch docker image with "docker buildx" and push it
docker-buildx-push:
	docker buildx build . -t ${IMG} --build-arg KUBECTL_VERSION=${KUBECTL_VERSION} \
								--platform ${PLATFORMS} \
								--push

# Check docker image manifest
docker-check-manifest:
	docker manifest inspect ${IMG}
