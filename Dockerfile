FROM elixir:1.13.3-alpine as build

RUN mkdir /app
WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

CMD iex -S mix