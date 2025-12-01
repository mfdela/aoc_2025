defmodule Aoc.Day01Test do
  use ExUnit.Case

  import Elixir.Aoc.Day01

  def test_input() do
    """
    L68
    L30
    R48
    L5
    R60
    L55
    L1
    L99
    R14
    L82
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

    assert result == 6
  end
end
