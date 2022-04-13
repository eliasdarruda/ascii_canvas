defmodule Ascii.Canvas.Elements do
  @moduledoc false

  defmodule Rect do
    @moduledoc false

    @attrs [:x, :y, :width, :height, :outline, :fill]

    @derive {Jason.Encoder, only: @attrs}
    defstruct @attrs
  end
end
