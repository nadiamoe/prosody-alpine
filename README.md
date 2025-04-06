# prosody-alpine

An alpine-based container image with `prosody` installed. This is released and tagged with the `prosody` version inside, which allow downstream packages that need prosody to pin this version safely.

## Using this image

This image is tagged as `ghcr.io/nadiamoe/prosody-alpine:PROSODYVERSION-ALPINEVERSION`, with both versions grepped from the `Dockerfile`. As the image is tagged on every push to `main`, it is unlikely but possible for that tag to be overwritten if changes to CI/CD or similar are merged. It is recommended to pin the digest of it:

```Dockerfile
FROM ghcr.io/nadiamoe/prosody-alpine:0.0.0@sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

That way, dependency bumping bots will create PRs when the tag is overwritten.
