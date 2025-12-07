defmodule Aoc.Day06 do
  def part1(args) do
    args
    |> clean_input()
    |> split_problems()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> clean_input()
    |> split_problems()
    |> Enum.map(&solve_problems_right_to_left/1)
    |> Enum.sum()
  end

  def clean_input(input) do
    rows =
      input
      |> String.split("\n", trim: true)

    max_length = rows |> Enum.map(&String.length/1) |> Enum.max()

    rows
    |> Enum.map(&String.pad_trailing(&1, max_length))
    |> Enum.map(&String.graphemes/1)
    |> transpose()
  end

  defp transpose(rows) do
    rows
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp split_problems(problems) do
    problems
    |> Enum.chunk_by(fn column ->
      # A separator column is all spaces
      Enum.all?(column, &(&1 == " "))
    end)
    |> Enum.reject(fn chunk ->
      # Remove separator chunks (all spaces)
      chunk |> List.first() |> Enum.all?(&(&1 == " "))
    end)
    |> Enum.map(&Enum.zip/1)
    |> Enum.map(fn row ->
      row
      |> Enum.map(&Tuple.to_list/1)
    end)
  end

  defp solve_problem(input) do
    operator = input |> List.last() |> Enum.join() |> String.trim()

    operands =
      input
      |> Enum.drop(-1)
      |> Enum.map(fn row -> row |> Enum.join() |> String.trim() end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)

    calculate(operands, operator)
  end

  defp calculate(operands, "+"), do: Enum.sum(operands)
  defp calculate(operands, "*"), do: Enum.product(operands)

  defp solve_problems_right_to_left(input) do
    # Read columns right-to-left within the problem
    operator = input |> List.last() |> Enum.join() |> String.trim()

    operands =
      input
      |> Enum.drop(-1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.zip()
      |> Enum.map(fn row ->
        row |> Tuple.to_list() |> Enum.join() |> String.trim() |> String.to_integer()
      end)

    calculate(operands, operator)
  end
end
