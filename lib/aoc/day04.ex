defmodule Aoc.Day04 do
  def part1(args) do
    args
    |> clean_input()
    |> find_cells_with_few_neighbors()
    |> Enum.count()
  end

  def part2(args) do
    args
    |> clean_input()
    |> count_removed_cells(0)
  end

  def clean_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {val, c} -> {{r, c}, val} end)
    end)
    |> Map.new()
  end

  def find_cells_with_few_neighbors(grid_map) do
    # The 8 adjacent positions (relative coordinates)
    directions = [
      {-1, -1},
      {0, -1},
      {1, -1},
      {-1, 0},
      {1, 0},
      {-1, 1},
      {0, 1},
      {1, 1}
    ]

    grid_map
    |> Enum.filter(fn {_pos, value} -> value == "@" end)
    |> Enum.filter(fn {{x, y}, _value} ->
      adjacent_count =
        directions
        |> Enum.count(fn {dx, dy} ->
          Map.get(grid_map, {x + dx, y + dy}) == "@"
        end)

      adjacent_count < 4
    end)
    |> Enum.map(fn {pos, _value} -> pos end)
  end

  defp count_removed_cells(grid_map, count) do
    cells_to_remove =
      grid_map
      |> find_cells_with_few_neighbors()

    case cells_to_remove do
      [] ->
        count

      _ ->
        remove_cells_with_few_neighbors(cells_to_remove, grid_map)
        |> count_removed_cells(count + length(cells_to_remove))
    end
  end

  defp remove_cells_with_few_neighbors(cells, grid_map) do
    cells
    |> Enum.reduce(grid_map, fn cell, acc ->
      Map.delete(acc, cell)
    end)
  end
end
