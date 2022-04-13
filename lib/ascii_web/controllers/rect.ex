defmodule AsciiWeb.Controllers.Rect do
  import Plug.Conn

  def init(args), do: args

  def call(conn, _data) do
    %{query_params: %{"value" => rect_params}} = fetch_query_params(conn)

    [x, y, width, height, outline, fill] = String.split(rect_params, ";")

    Ascii.Canvas.new_rect(
      String.to_integer(x),
      String.to_integer(y),
      String.to_integer(width),
      String.to_integer(height),
      :binary.bin_to_list(outline),
      :binary.bin_to_list(fill)
    )

    send_resp(conn, 200, "OK")
  end
end
