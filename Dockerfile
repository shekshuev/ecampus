# build stage
FROM hexpm/elixir:1.14.5-erlang-24.2.2-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git python3 curl nodejs npm

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV

COPY mix.exs mix.lock ./
RUN mix deps.get --only ${MIX_ENV}

RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/

RUN mix deps.compile

COPY assets/ assets/
RUN cd assets && npm install && cd ..
RUN mix assets.setup
RUN mix assets.build
RUN mix phx.digest

COPY priv priv
COPY lib lib
RUN mix compile

COPY config/runtime.exs config/
RUN mix release

# app stage
FROM alpine:3.18.9 AS app

ARG MIX_ENV

RUN apk add --no-cache libstdc++ openssl ncurses-libs

ENV USER=${MIX_ENV}
WORKDIR "/home/${USER}/app"

RUN addgroup -g 1000 -S "${USER}" && adduser -s /bin/sh -u 1000 -G "${USER}" -h "/home/${USER}" -D "${USER}" && su "${USER}"

USER "${USER}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/ecampus ./

CMD ["sh", "-c", "bin/ecampus eval Ecampus.Release.migrate && bin/ecampus start"]