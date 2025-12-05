defmodule Aoc.Day03 do
  def part1(args) do
    args
    |> clean_input()
    |> Enum.map(&select_k_digits(&1, 2))
    |> Enum.map(&(Enum.join(&1) |> String.to_integer()))
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> clean_input()
    |> Enum.map(&select_k_digits(&1, 12))
    |> Enum.map(&(Enum.join(&1) |> String.to_integer()))
    |> Enum.sum()
  end

  def clean_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  def select_k_digits(digits, k) do
    n = length(digits)
    select(digits, 0, k, n)
  end

  defp select(_digits, _pos, 0, _n), do: []

  defp select(digits, pos, remaining, n) do
    # Window: can start from pos up to position where we have enough digits left
    window_end = n - remaining

    # Find max digit in valid window
    {max_digit, max_idx} =
      digits
      |> Enum.slice(pos..window_end)
      |> Enum.with_index(pos)
      |> Enum.max_by(fn {digit, _idx} -> digit end)

    [max_digit | select(digits, max_idx + 1, remaining - 1, n)]
  end
end
