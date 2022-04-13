defmodule AsciiWeb.Router do
  use Plug.Router

  import Plug.Conn

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, "priv/static/index.html")
  end

  get("/new_rect", to: AsciiWeb.Controllers.Rect)
  match("/sse", to: AsciiWeb.Controllers.SSE)

  match _ do
    conn
    |> send_resp(404, "Whoops!")
  end
end
