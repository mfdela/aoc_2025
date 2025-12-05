defmodule Aoc.Day04Test do
  use ExUnit.Case

  import Elixir.Aoc.Day04

  def test_input() do
    """
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 13
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 43
  end
end
