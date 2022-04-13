defmodule Ascii.Geometry do
  alias Ascii.Canvas.Elements.Rect

  @type point :: %{x: integer(), y: integer()}
  @type rect_edges :: %{a: integer(), b: integer(), c: integer()}

  @doc """
  Build rect edges in the following format and return a,b,c as map

  ```TEXT
  A_________B
  |         |
  |         |
  |_________C
  ```
  """
  @spec build_rect_edges(%Rect{}) :: rect_edges()
  def build_rect_edges(%Rect{} = rect) do
    width = max(rect.width - 1, 1)
    height = max(rect.height - 1, 1)

    %{
      a: %{x: rect.x, y: rect.y},
      b: %{x: rect.x + width, y: rect.y},
      c: %{x: rect.x + width, y: rect.y + height}
    }
  end

  @doc """
  Returns a specified ASCII character (number) for Rect if its intended to fill or outline
  """
  @spec fill_rect_or_outline(integer(), integer(), %Rect{}, integer()) :: integer()
  def fill_rect_or_outline(x, y, %Rect{} = rect, blank_ascii) do
    cond do
      rect.outline == blank_ascii ->
        rect.fill

      x == rect.x ->
        rect.outline

      y == rect.y ->
        rect.outline

      x == rect.x + max(rect.width - 1, 1) ->
        rect.outline

      y == rect.y + max(rect.height - 1, 1) ->
        rect.outline

      true ->
        rect.fill
    end
  end

  @doc """
  Verifies if a specific point is contained in a rectangle
  """
  @spec point_in_rectangle?(point(), rect_edges()) :: boolean()
  def point_in_rectangle?(point, %Rect{} = rect) do
    rect_edges = build_rect_edges(rect)

    pAB = vector(rect_edges.a, rect_edges.b)
    pAM = vector(rect_edges.a, point)
    pBC = vector(rect_edges.b, rect_edges.c)
    pBM = vector(rect_edges.b, point)

    dotABAM = dot(pAB, pAM)
    dotABAB = dot(pAB, pAB)
    dotBCBM = dot(pBC, pBM)
    dotBCBC = dot(pBC, pBC)

    0 <= dotABAM && dotABAM <= dotABAB && 0 <= dotBCBM && dotBCBM <= dotBCBC
  end

  @doc false
  defp dot(u, v) do
    u.x * v.x + u.y * v.y
  end

  @doc false
  defp vector(p1, p2) do
    %{
      x: p2.x - p1.x,
      y: p2.y - p1.y
    }
  end
end
