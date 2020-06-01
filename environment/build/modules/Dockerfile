ARG BASE_IMAGE
ARG WORKER_IMAGE

FROM ${WORKER_IMAGE} as worker

COPY ./scripts C:/scripts
COPY ./packages C:/packages

SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

RUN "C:\\scripts\\Extract-Packages.ps1"

FROM ${BASE_IMAGE}

COPY --from=worker C:/modules C:/modules