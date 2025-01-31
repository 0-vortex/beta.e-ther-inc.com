FROM node:16-alpine as development

WORKDIR /app

RUN \
  apk update &&\
  apk add --update\
    autoconf\
    automake\
    file\
    nasm\
    musl-dev\
    gcc\
    curl\
    git\
    make\
    libtool\
    libpng\
    libpng-dev\
    libjpeg-turbo\
    libjpeg-turbo-dev\
    zlib\
    zlib-dev

COPY package.json ./
COPY npm-shrinkwrap.json ./
COPY .npmrc ./

RUN npm ci

COPY pages ./pages
COPY public ./public
COPY styles ./styles
COPY .env.production ./.env.production

CMD [ "npm", "start"]

FROM development as builder

RUN npm run build
RUN npm run export

FROM nginx:1.21-alpine as production

COPY --from=builder /app/out /usr/share/nginx/html
