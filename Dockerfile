# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG ALPINE_VERSION=3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS community-modules-dl

# This copies nothing of interest, but the build system will remember the returned etag header. Subsequent builds will
# reuse the cached layer until upstream returns a different etag.
ADD https://hg.prosody.im/prosody-modules/ /cache-buster.html

RUN apk --no-cache add mercurial
RUN hg clone https://hg.prosody.im/prosody-modules/ /prosody-modules

FROM alpine:${ALPINE_VERSION} AS core

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG PROSODY_VERSION=1.0.8242-r0
RUN apk add --no-cache tini "prosody=${PROSODY_VERSION}"

USER prosody
ENV __FLUSH_LOG=yes
ENTRYPOINT [ "/sbin/tini", "--", "prosody" ]

FROM core AS community

COPY --from=community-modules-dl /prosody-modules /usr/local/lib/prosody/prosody-modules
