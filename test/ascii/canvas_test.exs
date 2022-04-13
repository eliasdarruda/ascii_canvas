defmodule Ascii.CanvasTest do
  use ExUnit.Case, async: false

  alias Ascii.Canvas

  test "join canvas and receive canvas stream" do
    pid = self()
    response = Canvas.join(pid)
    canvas_server_pid = Process.whereis(Canvas)

    assert %Stream{} = response
    assert %Canvas.State{listeners: [^pid]} = :sys.get_state(canvas_server_pid)
  end

  test "add rect to canvas at coords (0, 0)" do
    Canvas.reset(10, 10)
    stream = Canvas.new_rect(0, 0, 3, 3, '#', '@')

    assert [
      [35, 35, 35, 32 | _],
      [35, 64, 35, 32 | _],
      [35, 35, 35, 32 | _],
      [32, 32, 32, 32 | _]
    ] = Enum.map(stream, & Enum.to_list/1) |> Enum.take(4)
  end

  test "add 1x1 rect to canvas at coords (0, 0)" do
    Canvas.reset(4, 4)
    stream = Canvas.new_rect(0, 0, 1, 1, '#', '#')

    assert [
      '##  ',
      '##  ',
      '    ',
      '    ',
    ] = Enum.map(stream, & Enum.to_list/1)
  end

  test "add 2x2 rect to canvas at coords (0, 0)" do
    Canvas.reset(4, 4)
    stream = Canvas.new_rect(0, 0, 2, 2, '#', '#')

    assert [
      '##  ',
      '##  ',
      '    ',
      '    ',
    ] = Enum.map(stream, & Enum.to_list/1)
  end

  test "reset emits event to listeners" do
    Canvas.join(self())
    stream = Canvas.reset(4, 4)

    assert_received {:reset, ^stream}
  end
end
