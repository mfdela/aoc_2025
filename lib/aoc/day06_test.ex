defmodule Aoc.Day06Test do
  use ExUnit.Case

  import Elixir.Aoc.Day06

  def test_input() do
    """
    123 328  51 64
     45 64  387 23
      6 98  215 314
    *   +   *   +
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 4_277_556
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 3_263_827
  end
end
