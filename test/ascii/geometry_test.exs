defmodule Ascii.GeometryTest do
  use ExUnit.Case, async: false

  alias Ascii.Geometry
  alias Ascii.Canvas.Elements.Rect

  test "point is in rect" do
    rect = %Rect{x: 0, y: 0, width: 3, height: 3}

    assert true == Geometry.point_in_rectangle?(%{x: 2, y: 2}, rect)
  end

  test "point is not in rect" do
    rect = %Rect{x: 0, y: 0, width: 3, height: 3}

    assert false == Geometry.point_in_rectangle?(%{x: 4, y: 4}, rect)
  end

  test "calculate rect edges" do
    rect = %Rect{x: 0, y: 0, width: 3, height: 3}
    edges = Geometry.build_rect_edges(rect)

    assert %{a: %{x: 0, y: 0}, b: %{x: 2, y: 0}, c: %{x: 2, y: 2}} = edges
  end
end
