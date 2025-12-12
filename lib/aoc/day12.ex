defmodule Aoc.Day12 do
  def part1(args) do
    %{shapes: shapes, regions: regions} =
      args
      |> clean_input()

    regions
    |> Enum.count(fn region ->
      can_fit_presents?(region, shapes)
    end)
  end

  def part2(args) do
    args
  end

  def clean_input(input) do
    {shapes_blocks, regions_blocks} =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.split_while(fn section ->
        # Shapes start with "N:"
        String.match?(section, ~r/^\d+:/)
      end)

    shapes = parse_shapes(shapes_blocks)
    regions = parse_regions(regions_blocks)

    %{shapes: shapes, regions: regions}
  end

  defp parse_shapes(blocks) do
    blocks
    |> Enum.map(&parse_shape/1)
    |> Map.new()
  end

  defp parse_shape(shape_block) do
    [header | rows] = String.split(shape_block, "\n", trim: true)

    index =
      header
      |> String.trim_trailing(":")
      |> String.to_integer()

    coordinates =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {char, _x} -> char == "#" end)
        |> Enum.map(fn {_char, x} -> {x, y} end)
      end)
      |> MapSet.new()

    {index, coordinates}
  end

  defp parse_regions([blocks]) do
    blocks
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_region/1)
  end

  defp parse_region(line) do
    [dimensions, counts_str] =
      String.split(line, ": ", parts: 2)

    [width, height] =
      dimensions
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)

    # Convert counts to list of shape indices
    # e.g., [1, 0, 1, 0, 3, 2] becomes [0, 2, 4, 4, 4, 5, 5]
    shapes =
      counts_str
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.filter(fn {count, _idx} -> count > 0 end)
      |> Enum.flat_map(fn {count, shape_idx} ->
        List.duplicate(shape_idx, count)
      end)

    %{width: width, height: height, shapes: shapes}
  end

  # Check if all presents can fit in the region
  defp can_fit_presents?(region, shape_defs) do
    present_shapes =
      region.shapes
      |> Enum.map(fn shape_idx ->
        Map.fetch!(shape_defs, shape_idx)
      end)
      # Sort by size (largest first) for better pruning
      |> Enum.sort_by(&MapSet.size/1, :desc)

    # Early check: if total area exceeds region area, impossible
    total_area = Enum.sum(Enum.map(present_shapes, &MapSet.size/1))
    region_area = region.width * region.height

    if total_area > region_area do
      false
    else
      # Pre-compute all unique orientations for each shape
      shapes_with_orientations =
        Enum.map(present_shapes, fn shape ->
          get_all_orientations(shape)
        end)

      # Try to place all presents using backtracking with a visit limit
      {result, _visits} = place_presents(shapes_with_orientations, region, MapSet.new(), 0, 1_000_000)
      result
    end
  end

  # Backtracking algorithm to place all presents
  defp place_presents([], _region, _occupied, visits, _max_visits), do: {true, visits}

  defp place_presents(_shapes, _region, _occupied, visits, max_visits) when visits > max_visits do
    {false, visits}
  end

  defp place_presents([orientations | rest], region, occupied, visits, max_visits) do
    # Get candidate positions (reduce search space)
    candidate_positions = get_smart_positions(region, occupied)

    # Try all orientations
    result =
      Enum.reduce_while(orientations, {false, visits}, fn oriented_shape, {_found, visit_count} ->
        # Try candidate positions only
        pos_result =
          Enum.reduce_while(candidate_positions, {false, visit_count}, fn {x, y}, {_found, vc} ->
            placed_coords = translate_shape(oriented_shape, x, y)

            if can_place?(placed_coords, region, occupied) do
              # Place it and try to place the rest
              new_occupied = MapSet.union(occupied, placed_coords)
              {success, new_visits} = place_presents(rest, region, new_occupied, vc + 1, max_visits)

              if success do
                {:halt, {true, new_visits}}
              else
                {:cont, {false, new_visits}}
              end
            else
              {:cont, {false, vc + 1}}
            end
          end)

        case pos_result do
          {true, v} -> {:halt, {true, v}}
          {false, v} -> {:cont, {false, v}}
        end
      end)

    result
  end

  # Get smart positions to try - positions adjacent to occupied cells
  defp get_smart_positions(region, occupied) do
    if MapSet.size(occupied) == 0 do
      # First shape: try origin and a few other positions
      [{0, 0}]
    else
      # Get all empty cells adjacent to occupied cells
      occupied
      |> Enum.flat_map(fn {x, y} ->
        [
          {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
          {x - 1, y}, {x + 1, y},
          {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
        ]
      end)
      |> Enum.filter(fn {x, y} ->
        x >= 0 and x < region.width and y >= 0 and y < region.height and
          not MapSet.member?(occupied, {x, y})
      end)
      |> Enum.uniq()
      |> Enum.sort()
    end
  end

  # Generate all 8 possible orientations (4 rotations × 2 flips)
  defp get_all_orientations(shape) do
    rotations = [
      shape,
      rotate_90(shape),
      rotate_180(shape),
      rotate_270(shape)
    ]

    flipped_rotations = Enum.map(rotations, &flip_horizontal/1)

    (rotations ++ flipped_rotations)
    |> Enum.uniq()
  end

  # Rotate 90 degrees clockwise: (x, y) -> (y, -x)
  defp rotate_90(shape) do
    shape
    |> Enum.map(fn {x, y} -> {y, -x} end)
    |> normalize_shape()
  end

  # Rotate 180 degrees: (x, y) -> (-x, -y)
  defp rotate_180(shape) do
    shape
    |> Enum.map(fn {x, y} -> {-x, -y} end)
    |> normalize_shape()
  end

  # Rotate 270 degrees clockwise: (x, y) -> (-y, x)
  defp rotate_270(shape) do
    shape
    |> Enum.map(fn {x, y} -> {-y, x} end)
    |> normalize_shape()
  end

  # Flip horizontally: (x, y) -> (-x, y)
  defp flip_horizontal(shape) do
    shape
    |> Enum.map(fn {x, y} -> {-x, y} end)
    |> normalize_shape()
  end

  # Normalize shape so the top-left corner is at (0, 0)
  defp normalize_shape(coords) do
    coords_list = if is_list(coords), do: coords, else: MapSet.to_list(coords)
    min_x = Enum.min_by(coords_list, fn {x, _} -> x end) |> elem(0)
    min_y = Enum.min_by(coords_list, fn {_, y} -> y end) |> elem(1)

    coords_list
    |> Enum.map(fn {x, y} -> {x - min_x, y - min_y} end)
    |> MapSet.new()
  end

  # Translate shape to position (dx, dy)
  defp translate_shape(shape, dx, dy) do
    shape
    |> Enum.map(fn {x, y} -> {x + dx, y + dy} end)
    |> MapSet.new()
  end

  # Check if a shape can be placed at the given coordinates
  defp can_place?(coords, region, occupied) do
    Enum.all?(coords, fn {x, y} ->
      # Must be within bounds
      x >= 0 and x < region.width and y >= 0 and y < region.height and
        # Must not overlap with already placed presents
        not MapSet.member?(occupied, {x, y})
    end)
  end
end
