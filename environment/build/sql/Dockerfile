ARG BASE_IMAGE
ARG MODULES_IMAGE

FROM ${MODULES_IMAGE} as modules
FROM ${BASE_IMAGE} as base

COPY --from=modules C:/modules/sql c:/temp
COPY ./scripts C:/scripts

RUN powershell "C:\\scripts\\Install-Modules.ps1"; \
    Remove-Item "C:\\scripts" -Force -Recurse; \
    Remove-Item "C:\\temp" -Force -Recurse
