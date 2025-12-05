defmodule Aoc.Day03Test do
  use ExUnit.Case

  import Elixir.Aoc.Day03

  def test_input() do
    """
    987654321111111
    811111111111119
    234234234234278
    818181911112111
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 357
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 3_121_910_778_619
  end
end
