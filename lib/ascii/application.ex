defmodule Ascii.Application do
  @moduledoc false

  use Application
  require Logger

  @cowboy_options [
    port: 4000,
    compress: true,
    protocol_options: [idle_timeout: :infinity]
  ]

  @impl true
  def start(_type, _args) do
    children = [
      {Ascii.Canvas, width: 50, height: 50},
      {Plug.Cowboy, plug: AsciiWeb.Router, scheme: :http, options: @cowboy_options}
    ]

    opts = [strategy: :one_for_one, name: Ascii.Supervisor]
    Logger.debug "Server listening on port #{@cowboy_options[:port]}"
    Supervisor.start_link(children, opts)
  end
end
