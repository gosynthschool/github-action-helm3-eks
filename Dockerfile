FROM alpine/helm:3.10.1 AS runtime
ARG HELMFILE_VERSION=0.144.0
# hadolint ignore=DL3002
USER root

ENV GLIBC_VER=2.31-r0

# hadolint ignore=DL3018
RUN apk --no-cache add \
    git less openssh bash \
    binutils \
    curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk \
    && curl -sL -o helmfile_linux_amd64 https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 \
    && apk add --no-cache \
    glibc-${GLIBC_VER}.apk \
    glibc-bin-${GLIBC_VER}.apk \
    glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.10.3.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && aws/install \
    && mv helmfile_linux_amd64 /usr/local/bin/helmfile \
    && chmod +x /usr/local/bin/helmfile \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    helmfile_linux_amd64 \
    glibc-*.apk \
    && apk --no-cache del \
    binutils \
    curl \
    && rm -rf /var/cache/apk/*

RUN  /usr/local/bin/aws --version

RUN helm plugin install https://github.com/databus23/helm-diff --version v3.6.0 && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version v4.1.1 && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git --version v0.14.0 && \
    helm plugin install https://github.com/aslafy-z/helm-git.git --version v0.13.0

RUN mkdir /workdir
COPY entrypoint.sh /workdir/entrypoint.sh
RUN chmod +x /workdir/entrypoint.sh

ENTRYPOINT ["/workdir/entrypoint.sh"]
