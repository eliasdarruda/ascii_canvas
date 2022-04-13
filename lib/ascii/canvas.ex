defmodule Ascii.Canvas do
  use GenServer

  alias Ascii.Canvas.Elements.Rect
  alias Ascii.Geometry

  @blank_ascii 32
  @default_width 50
  @default_height 50

  defmodule Config do
    @derive {Jason.Encoder, only: [:width, :height]}
    defstruct [:width, :height]
  end

  defmodule State do
    defstruct listeners: [], config: %Ascii.Canvas.Config{}, canvas_stream: nil
  end

  def init(args) do
    config = %Config{
      width: args[:width] || @default_width,
      height: args[:height] || @default_height
    }

    canvas_stream =
      Stream.map(0..config.width, fn _row ->
        Stream.map(0..config.height, fn _ -> @blank_ascii end)
      end)

    {:ok, %State{config: config, canvas_stream: canvas_stream}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, %State{} = state) do
    {:noreply, %State{state | listeners: state.listeners -- [pid]}}
  end

  def handle_call({:new_rect, %Rect{} = rect}, _from, state) do
    canvas_stream =
      state.canvas_stream
      |> Stream.with_index()
      |> Stream.map(fn {row_stream, y} ->
        row_stream
        |> Stream.with_index()
        |> Stream.map(fn {char, x} ->
          case Geometry.point_in_rectangle?(%{x: x, y: y}, rect) do
            true ->
              Geometry.fill_rect_or_outline(x, y, rect, @blank_ascii)

            false ->
              char
          end
        end)
      end)

    broadcast_new_rect(state.listeners, rect, canvas_stream)

    {:reply, canvas_stream, %State{state | canvas_stream: canvas_stream}}
  end

  def handle_call({:join, pid}, _from, state) do
    Process.monitor(pid)

    {:reply, state.canvas_stream, %State{state | listeners: state.listeners ++ [pid]}}
  end

  # CLIENT

  def start_link(listeners) do
    GenServer.start_link(__MODULE__, listeners, timeout: 5_000, name: __MODULE__)
  end

  def join(pid) do
    GenServer.call(__MODULE__, {:join, pid})
  end

  def new_rect(x, y, width, height, outline \\ [@blank_ascii], fill \\ [@blank_ascii]) do
    outline = Enum.at(outline, 0)
    fill = Enum.at(fill, 0)

    rect = %Rect{x: x, y: y, width: width, height: height, outline: outline, fill: fill}

    GenServer.call(__MODULE__, {:new_rect, rect})
  end

  defp broadcast_new_rect(listeners, rect, canvas_stream) do
    Enum.each(listeners, fn listener ->
      send(listener, {:new_rect, rect, canvas_stream})
    end)
  end
end
