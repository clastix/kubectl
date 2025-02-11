# Image URL to use while building/pushing image targets
IMG ?= quay.io/clastix/kubectl:${KUBECTL_VERSION}

# Choose kubectl version from commit sha related tag
# if no tag comes out, it will use "stable" binary
KUBECTL_URL ?= https://storage.googleapis.com/kubernetes-release/release/stable.txt
KUBECTL_VERSION ?= $$(git describe --abbrev=0 --tags || curl -s ${KUBECTL_URL})

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

# Build multi-platform docker image and push it
# QEMU and binfmt-support pkgs are required
docker-buildx-push:
	docker buildx build . -t ${IMG} --build-arg KUBECTL_VERSION=${KUBECTL_VERSION} \
								--platform ${PLATFORMS} \
								--push

# Check multiarch docker image manifest
docker-check-manifest:
	docker manifest inspect ${IMG}

docker-trivy-scan:
	docker run --rm -v trivy-cache:/root/.cache/ \
					-v /var/run/docker.sock:/var/run/docker.sock \
					aquasec/trivy:0.59.1 \
					image ${IMG}
