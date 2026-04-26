FROM node:24-alpine AS builder

RUN apk update && \
    apk add --no-cache git ffmpeg wget curl bash openssl

LABEL version="2.3.7" description="ACM Digital - API para controle de funcionalidades WhatsApp via HTTP."
LABEL maintainer="ACM Digital" git="https://github.com/acmdigital"
LABEL contact="contato@acmdigital.com.br"

WORKDIR /acm-digital

COPY ./package*.json ./
COPY ./tsconfig.json ./
COPY ./tsup.config.ts ./

RUN npm ci --silent

COPY ./src ./src
COPY ./public ./public
COPY ./prisma ./prisma
COPY ./manager ./manager
COPY ./.env.example ./.env
COPY ./runWithProvider.js ./

COPY ./Docker ./Docker

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*

RUN ./Docker/scripts/generate_database.sh

RUN npm run build

FROM node:24-alpine AS final

RUN apk update && \
    apk add tzdata ffmpeg bash openssl

ENV TZ=America/Sao_Paulo
ENV DOCKER_ENV=true

WORKDIR /acm-digital

COPY --from=builder /acm-digital/package.json ./package.json
COPY --from=builder /acm-digital/package-lock.json ./package-lock.json

COPY --from=builder /acm-digital/node_modules ./node_modules
COPY --from=builder /acm-digital/dist ./dist
COPY --from=builder /acm-digital/prisma ./prisma
COPY --from=builder /acm-digital/manager ./manager
COPY --from=builder /acm-digital/public ./public
COPY --from=builder /acm-digital/.env ./.env
COPY --from=builder /acm-digital/Docker ./Docker
COPY --from=builder /acm-digital/runWithProvider.js ./runWithProvider.js
COPY --from=builder /acm-digital/tsup.config.ts ./tsup.config.ts

ENV DOCKER_ENV=true

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c", ". ./Docker/scripts/deploy_database.sh && npm run start:prod" ]
