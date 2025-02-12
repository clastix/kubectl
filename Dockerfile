FROM alpine:3.21.2

ARG KUBECTL_VERSION
ARG TARGETARCH

RUN echo -e "-----------------\nKubectl: ${KUBECTL_VERSION}\nArch: ${TARGETARCH}\n-----------------\n"
RUN apk add --no-cache -U -u \
            ca-certificates \
            curl
RUN curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x /usr/local/bin/kubectl
RUN addgroup -g 1000 -S nonroot && \
    adduser -u 1000 -D -S -G nonroot nonroot

RUN kubectl version --client

USER nonroot
ENTRYPOINT ["kubectl"]
