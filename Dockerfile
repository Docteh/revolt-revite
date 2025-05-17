FROM --platform=$BUILDPLATFORM node:16-buster AS builder

WORKDIR /usr/src/app
COPY . .
COPY .env.build .env

RUN yarn install --frozen-lockfile
RUN yarn build:deps
# RUN yarn typecheck # lol no
RUN yarn build:highmem
RUN yarn workspaces focus --production --all

FROM node:22-alpine
WORKDIR /usr/src/app
COPY package.json.docker package.json
COPY yarn.lock.docker yarn.lock
RUN yarn install
COPY scripts/inject.js scripts/inject.js
COPY --from=builder /usr/src/app/dist dist

EXPOSE 5000
CMD [ "yarn", "start:inject" ]
