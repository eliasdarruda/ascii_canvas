defmodule Ascii.Canvas.Elements do
  defmodule Rect do
    @attrs [:x, :y, :width, :height, :outline, :fill]

    @derive {Jason.Encoder, only: @attrs}
    defstruct @attrs
  end
end
