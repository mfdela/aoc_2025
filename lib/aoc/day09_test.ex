defmodule Aoc.Day09Test do
  use ExUnit.Case

  import Elixir.Aoc.Day09

  def test_input() do
    """
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 50
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 24
  end
end
