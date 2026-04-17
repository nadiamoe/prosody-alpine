# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG ALPINE_VERSION=3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS community-modules-dl

# This copies nothing of interest, but the build system will remember the returned etag header. Subsequent builds will
# reuse the cached layer until upstream returns a different etag.
ADD https://hg.prosody.im/prosody-modules/ /cache-buster.html

RUN apk --no-cache add mercurial
RUN hg clone https://hg.prosody.im/prosody-modules/ /prosody-modules

FROM alpine:${ALPINE_VERSION} AS core

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG PROSODY_VERSION=13.0.2-r0
RUN apk add --no-cache tini "prosody=${PROSODY_VERSION}"

USER prosody
ENV __FLUSH_LOG=yes
ENTRYPOINT [ "/sbin/tini", "--", "prosody" ]

FROM core AS community

COPY --from=community-modules-dl /prosody-modules /usr/local/lib/prosody/prosody-modules
