FROM alpine:3.14.2

ARG KUBECTL_VERSION
ARG TARGETARCH

RUN echo -e "-----------------\nKubectl: ${KUBECTL_VERSION}\nArch: ${TARGETARCH}\n-----------------\n" && \
    apk add --no-cache --update \
            ca-certificates \
            curl && \
    curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    addgroup -g 1000 -S nonroot && \
    adduser -u 1000 -D -S -G nonroot nonroot

RUN kubectl version --client

USER nonroot
ENTRYPOINT ["kubectl"]
