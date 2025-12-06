defmodule Aoc.Day05Test do
  use ExUnit.Case

  import Elixir.Aoc.Day05

  def test_input() do
    """
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 3
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 14
  end
end
