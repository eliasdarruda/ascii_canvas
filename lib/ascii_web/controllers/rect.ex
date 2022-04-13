defmodule AsciiWeb.Controllers.Rect do
  @moduledoc """
  This is the Rect Controller, this just handles adding new rects in the most naive way possible
  """

  import Plug.Conn

  def init(args), do: args

  def call(conn, _data) do
    %{query_params: %{"value" => rect_params}} = fetch_query_params(conn)

    [x, y, width, height, outline, fill] = rect_params |> Base.url_decode64! |> String.split(";")

    Ascii.Canvas.new_rect(
      String.to_integer(x),
      String.to_integer(y),
      String.to_integer(width),
      String.to_integer(height),
      :binary.bin_to_list(outline),
      :binary.bin_to_list(fill)
    )

    send_resp(conn, 200, "OK")
  rescue
    _ -> send_resp(conn, 400, "Invalid Format")
  end
end
