# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG ALPINE_VERSION=3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS mod-http-upload-s3

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ADD https://github.com/LittleFox94/prosody-mod_http_upload_s3/archive/f5f1ab6e28923d434ebf481edbbb6d4962af6dd9.tar.gz /download/prosody-mod_http_upload_s3.tar.gz
RUN <<EOF
  set -e
  mkdir /out
  tar -xzvf /download/prosody-mod_http_upload_s3.tar.gz -C /out
  mv /out/prosody-mod_http_upload_s3* /mod_http_upload_s3
EOF

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS community-modules-dl

# This copies nothing of interest, but the build system will remember the returned etag header. Subsequent builds will
# reuse the cached layer until upstream returns a different etag.
ADD https://hg.prosody.im/prosody-modules/ /cache-buster.html

RUN apk --no-cache add mercurial
RUN hg clone https://hg.prosody.im/prosody-modules/ /prosody-modules

FROM alpine:${ALPINE_VERSION} AS core

# Renovate and CI/CD interact with the following line. Keep its format as it is.
ARG PROSODY_VERSION=13.0.6-r0
RUN apk add --no-cache tini "prosody=${PROSODY_VERSION}"

USER prosody
ENV __FLUSH_LOG=yes
ENTRYPOINT [ "/sbin/tini", "--", "prosody" ]

FROM core AS community

COPY --from=community-modules-dl /prosody-modules /usr/local/lib/prosody/prosody-modules
COPY --from=mod-http-upload-s3 /mod_http_upload_s3 /usr/local/lib/prosody/prosody-modules/mod_http_upload_s3
