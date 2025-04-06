# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG ALPINE_VERSION=3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

FROM alpine:${ALPINE_VERSION}

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG PROSODY_VERSION=0.12.4-r2
RUN apk add --no-cache tini "prosody=${PROSODY_VERSION}"

USER prosody
ENV __FLUSH_LOG=yes
ENTRYPOINT [ "/sbin/tini", "--", "prosody" ]
