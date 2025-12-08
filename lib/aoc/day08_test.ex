defmodule Aoc.Day08Test do
  use ExUnit.Case

  import Elixir.Aoc.Day08

  def test_input() do
    """
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
    """
  end

  test "part1" do
    input = test_input()

    {ordered_points, circuits} = process_input(input)

    result =
      find_circuits(Enum.take(ordered_points, 10), circuits)
      |> process_output()

    assert result == 40
  end

  test "part2" do
    input = test_input()
    result = part2(input)

    assert result == 25272
  end
end
