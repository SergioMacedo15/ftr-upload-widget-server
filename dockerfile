FROM node:20.18 as base

RUN npm i -g pnpm 

FROM base as dependecies 

WORKDIR /usr/src/app
COPY package.json pnpm-lock.yaml ./
RUN pnpm i

FROM base as build

WORKDIR /usr/src/app
COPY . .
COPY --from=dependecies /usr/src/app/node_modules ./node_modules

RUN pnpm build 
RUN pnpm prune --prod


FROM node:20-alpine3.21 as deploy

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json


ENV CLOUDFLARE_ACCESS_KEY_ID="6648012f020e762d80d9e59a609cf255"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="565c5a3b995bc63c3e8d54e18cc0a7a21e8cf97e5438f0d8ff39babfe0793b5b"
ENV CLOUDFLARE_BUCKET="pos-widget-image"
ENV CLOUDFLARE_ACCOUNT_ID="30db21224133565e4e45a2d511a6504a"
ENV CLOUDFLARE_PUBLIC_URL="https://pub-a45992d649814861bb0221a0b249b919.r2.dev"

EXPOSE 3333

CMD [ "node", "dist/server.mjs" ]