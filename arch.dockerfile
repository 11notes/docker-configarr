# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_ROOT=/configarr \
      BUILD_SRC=raydak-labs/configarr.git \
      BUILD_ROOT=/configarr

# :: FOREIGN IMAGES
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:node-stable AS distroless-node
  FROM 11notes/distroless:git AS distroless-git


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: CRON
  FROM 11notes/go:1.25 AS cron
  COPY ./build /
  ARG APP_VERSION \
      BUILD_ROOT=/go/cron \
      BUILD_BIN=/go/cron/cron

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    eleven go build ${BUILD_BIN} main.go;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: CONFIGARR
  FROM node:lts-alpine AS build
  COPY --from=util-bin / /
  ARG APP_VERSION \
      BUILD_SRC \
      BUILD_ROOT

  RUN set -ex; \
    apk --update --no-cache add \
      git \
      pnpm;

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    sed -i 's#${getEnvs().ROOT_PATH}/config#${getEnvs().ROOT_PATH}/etc#g' ./src/env.ts; \
    sed -i 's#${getEnvs().ROOT_PATH}/repos#${getEnvs().ROOT_PATH}/var#g' ./src/env.ts;

  RUN set -ex; \
    npm install -g npm; \
    npm install -g corepack; \
    corepack enable; \
    corepack prepare pnpm; \
    corepack use pnpm;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
      pnpm install;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
      pnpm run build;

  RUN set -ex; \
    mkdir -p /distroless/opt/configarr; \
    mv ${BUILD_ROOT}/bundle.cjs /distroless/opt/configarr;

# :: FILE-SYSTEM
  FROM alpine AS file-system
  COPY ./rootfs /distroless
  ARG APP_ROOT
  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc; \
    mkdir -p /distroless${APP_ROOT}/var;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE \
        BUILD_ROOT

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV NODE_ENV=production \
        CONFIGARR_VERSION=v${APP_VERSION} \
        GIT_TEMPLATE_DIR=/opt/git/templates \
        GIT_EXEC_PATH=/opt/git

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-node / /
    COPY --from=distroless-git / /
    COPY --from=cron /distroless/ /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/cron", "--ping"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  WORKDIR ${APP_ROOT}
  ENTRYPOINT ["/usr/local/bin/cron"]