defmodule Aoc.Day01 do
  def part1(args) do
    args
    |> clean_input()
    |> rotate_dial()
    |> elem(1)
  end

  def part2(args) do
    args
    |> clean_input()
    |> rotate_dial()
    |> elem(2)
  end

  def clean_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line = String.trim(line)

      if line != "" do
        direction = String.at(line, 0)
        number = String.slice(line, 1..-1//1) |> String.to_integer()

        case direction do
          "L" -> -number
          "R" -> number
        end
      end
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def rotate_dial(input) do
    input
    |> Enum.reduce({50, 0, 0}, fn val, {curr_pos, count_zero, count_pass_zero} ->
      new_pos = curr_pos + val

      n = Integer.mod(new_pos, 100)

      # counts the times the dial ends in the zero position
      cz =
        case n do
          0 -> count_zero + 1
          _ -> count_zero
        end

      # counts the zero crossings
      cpz =
        cond do
          new_pos <= 0 and curr_pos != 0 -> count_pass_zero + abs(div(new_pos, 100)) + 1
          true -> count_pass_zero + abs(div(new_pos, 100))
        end

      {n, cz, cpz}
    end)
  end
end
