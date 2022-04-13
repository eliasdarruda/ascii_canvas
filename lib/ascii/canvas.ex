defmodule Ascii.Canvas do
  @moduledoc """
  This is a Process Manager that monitors pids and act as pub-sub to communicate events to all listeners,
  it initializes inputting width and height for the canvas

  Here you can basically join to be notified of the new rectangles and add a new rect
  """

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

  @doc false
  def init(args) do
    config = %Config{
      width: args[:width] || @default_width,
      height: args[:height] || @default_height
    }

    canvas_stream = blank_canvas_stream(config)

    {:ok, %State{config: config, canvas_stream: canvas_stream}}
  end

  @doc false
  def handle_info({:DOWN, _ref, :process, pid, _reason}, %State{} = state) do
    {:noreply, %State{state | listeners: state.listeners -- [pid]}}
  end

  @doc false
  def handle_call({:reset, width, height}, _from, %State{config: config} = state) do
    config = %Config{config | width: width || config.width, height: height || config.height}
    canvas_stream = blank_canvas_stream(config)

    broadcast_reset(state.listeners, canvas_stream)

    {:reply, canvas_stream, %State{state | config: config, canvas_stream: canvas_stream}}
  end

  @doc false
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

  @doc false
  def handle_call({:join, pid}, _from, state) do
    Process.monitor(pid)

    {:reply, state.canvas_stream, %State{state | listeners: state.listeners ++ [pid]}}
  end

  # CLIENT

  @doc false
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, timeout: 5_000, name: __MODULE__)
  end

  @doc """
  Subscribes to canvas to receive its messages

  Returns the in memory canvas stream
  """
  @spec join(pid()) :: %Stream{}
  def join(pid) do
    GenServer.call(__MODULE__, {:join, pid})
  end

  @doc """
  Adds a new rect to canvas stream, the mininum possible rect is 2x2, otherwise its a point, not a rect
  (if inputted 1x1 it should be the same as 2x2)

  Returns the in memory canvas stream
  """
  @spec new_rect(integer, integer, integer, integer, integer, integer) :: %Stream{}
  def new_rect(x, y, width, height, outline \\ [@blank_ascii], fill \\ [@blank_ascii]) do
    outline = Enum.at(outline, 0)
    fill = Enum.at(fill, 0)

    rect = %Rect{x: x, y: y, width: width, height: height, outline: outline, fill: fill}

    GenServer.call(__MODULE__, {:new_rect, rect})
  end

  @doc """
  Reset the canvas with the option of specifying new Width x Height
  """
  @spec reset(integer() | nil, integer | nil) :: %Stream{}
  def reset(width \\ nil, height \\ nil) do
    GenServer.call(__MODULE__, {:reset, width, height})
  end

  @doc false
  defp blank_canvas_stream(config) do
    Stream.map(0..config.width - 1, fn _row ->
      Stream.map(0..config.height - 1, fn _ -> @blank_ascii end)
    end)
  end

  defp broadcast_new_rect(listeners, rect, canvas_stream) do
    Enum.each(listeners, fn listener ->
      send(listener, {:new_rect, rect, canvas_stream})
    end)
  end

  defp broadcast_reset(listeners, canvas_stream) do
    Enum.each(listeners, fn listener ->
      send(listener, {:reset, canvas_stream})
    end)
  end
end
