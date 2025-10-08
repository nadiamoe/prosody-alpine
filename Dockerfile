# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG ALPINE_VERSION=3.22.2@sha256:265b17e252b9ba4c7b7cf5d5d1042ed537edf6bf16b66130d93864509ca5277f

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS community-modules-dl

# This copies nothing of interest, but the build system will remember the returned etag header. Subsequent builds will
# reuse the cached layer until upstream returns a different etag.
ADD https://hg.prosody.im/prosody-modules/ /cache-buster.html

RUN apk --no-cache add mercurial
RUN hg clone https://hg.prosody.im/prosody-modules/ /prosody-modules

FROM alpine:${ALPINE_VERSION} AS core

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG PROSODY_VERSION=0.12.5-r1
RUN apk add --no-cache tini "prosody=${PROSODY_VERSION}"

USER prosody
ENV __FLUSH_LOG=yes
ENTRYPOINT [ "/sbin/tini", "--", "prosody" ]

FROM core AS community

COPY --from=community-modules-dl /prosody-modules /usr/local/lib/prosody/prosody-modules
