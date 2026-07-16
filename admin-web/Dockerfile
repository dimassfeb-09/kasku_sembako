FROM oven/bun:1 AS build
WORKDIR /app
COPY package.json bun.lock ./
RUN NODE_TLS_REJECT_UNAUTHORIZED=0 bun install --frozen-lockfile
COPY . .
RUN bun run build

FROM nginx:alpine
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
