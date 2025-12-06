defmodule Aoc.Day05 do
  def part1(args) do
    {ranges, ids} =
      args
      |> clean_input()

    count_ids_in_ranges(ranges, ids)
  end

  def part2(args) do
    {ranges, _ids} =
      args
      |> clean_input()

    merge_ranges(ranges)
    |> Enum.map(fn {start, finish} -> finish - start + 1 end)
    |> Enum.sum()
  end

  def clean_input(input) do
    [ranges_section, ids_section] =
      input
      |> String.split("\n\n", trim: true)

    ranges =
      ranges_section
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "-", trim: true))
      |> Enum.map(fn [start, finish] -> {String.to_integer(start), String.to_integer(finish)} end)

    ids =
      ids_section
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {ranges, ids}
  end

  def count_ids_in_ranges(ranges, ids) do
    ids
    |> Enum.count(fn id ->
      Enum.any?(ranges, fn {start, finish} -> id >= start and id <= finish end)
    end)
  end

  def merge_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn {start, _finish} -> start end)
    |> Enum.reduce([], fn {range_start, range_finish}, acc ->
      case acc do
        [] ->
          [{range_start, range_finish}]

        [{current_start, current_finish} | rest] ->
          if range_start <= current_finish + 1 do
            # Overlapping or adjacent - merge them
            merged = {current_start, max(current_finish, range_finish)}
            [merged | rest]
          else
            # No overlap - add new range
            [{range_start, range_finish}, {current_start, current_finish} | rest]
          end
      end
    end)
    |> Enum.reverse()
  end
end
