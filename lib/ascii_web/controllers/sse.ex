defmodule AsciiWeb.Controllers.SSE do
  import Plug.Conn

  def init(args), do: args

  def call(conn, _opts) do
    canvas_stream = Ascii.Canvas.join(self())

    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> send_chunked(200)
    |> send_canvas_stream(Stream.with_index(canvas_stream))
    |> listen_for_events()
  end

  defp listen_for_events(conn) do
    receive do
      {:new_rect, rect, canvas_stream} ->
        sliced_canvas_lines =
          canvas_stream
          |> Stream.with_index()
          |> Enum.slice(rect.y..(rect.y + rect.height - 1))

        send_canvas_stream(conn, sliced_canvas_lines)

        listen_for_events(conn)
    end
  end

  defp send_canvas_stream(conn, canvas_stream) do
    canvas_stream
    |> Enum.reduce_while(conn, fn {line, index}, conn ->
      line = Enum.to_list(line)

      case send_message(conn, build_canvas_line_message(line, index)) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end

  defp build_canvas_line_message(line, index) do
    %{new_line: %{number: index, content: line}}
  end

  defp send_message(conn, term) do
    {:ok, json} = Jason.encode(term)

    chunk(conn, "event: \"message\"\n\ndata: #{json}\n\n")
  end
end
