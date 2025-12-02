defmodule Aoc.Day02 do
  def part1(args) do
    args
    |> clean_input()
    |> find_invalid(false)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> clean_input()
    |> find_invalid(true)
    |> Enum.sum()
  end

  def clean_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.map(fn [a, b] -> [String.to_integer(a), String.to_integer(b)] end)
  end

  def find_invalid(list, multiple_repetitions \\ false) do
    find_invalid(list, [], multiple_repetitions)
  end

  def find_invalid([], acc, _multiple_repetitions) do
    acc
  end

  def find_invalid([[a, b] | rest], acc, multiple_repetitions) do
    # IO.inspect([a, b], label: "Input Pair")
    # check if repeated digits
    acc =
      a..b
      |> Enum.filter(&has_repeated_digits?(&1, multiple_repetitions))
      |> Kernel.++(acc)

    find_invalid(rest, acc, multiple_repetitions)
  end

  defp has_repeated_digits?(n, multiple_repetitions) when is_integer(n) do
    str = Integer.to_string(n)
    len = String.length(str)

    if len == 1 or (rem(len, 2) != 0 and not multiple_repetitions) do
      false
    else
      has_repeated_digits?(str, len, multiple_repetitions)
    end
  end

  defp has_repeated_digits?(str, len, multiple_repetitions) when is_binary(str) do
    # Check if it's composed of repeated patterns (123123, etc.)
    Enum.any?(1..div(len, 2), fn pattern_len ->
      if rem(len, pattern_len) == 0 do
        pattern = String.slice(str, 0, pattern_len)
        repetitions = div(len, pattern_len)

        String.duplicate(pattern, repetitions) == str and
          (multiple_repetitions or repetitions == 2) and repetitions >= 2
      else
        false
      end
    end)
  end
end
