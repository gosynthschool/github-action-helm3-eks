FROM alpine/helm:3.4.1 AS runtime

# hadolint ignore=DL3002
USER root

# hadolint ignore=DL3018
RUN apk --no-cache --update add git less openssh bash \
    && apk --no-cache add curl \
    && apk --no-cache add unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN mkdir /workdir
COPY entrypoint.sh /workdir/entrypoint.sh
RUN chmod +x /workdir/entrypoint.sh

ENTRYPOINT ["/workdir/entrypoint.sh"]
