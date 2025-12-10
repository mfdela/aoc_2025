defmodule Aoc.Day10Test do
  use ExUnit.Case

  import Elixir.Aoc.Day10

  def test_input() do
    """
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    """
  end

  test "part1" do
    input = test_input()
    result = part1(input)

    assert result == 7
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 33
  end
end
