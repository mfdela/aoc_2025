defmodule Aoc.Day12Test do
  use ExUnit.Case

  import Elixir.Aoc.Day12

  def test_input() do
    """
    0:
    ###
    ##.
    ##.

    1:
    ###
    ##.
    .##

    2:
    .##
    ###
    ##.

    3:
    ##.
    ###
    ##.

    4:
    ###
    #..
    ###

    5:
    ###
    .#.
    ###

    4x4: 0 0 0 0 2 0
    12x5: 1 0 1 0 2 2
    12x5: 1 0 1 0 3 2
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 2
  end
end
