defmodule Aoc.Day12 do
  @max_visits 1_000_000

  def part1(args) do
    %{shapes: shapes, regions: regions} =
      args
      |> clean_input()

    # Parallel processing for significant speedup
    regions
    |> Task.async_stream(
      fn region -> can_fit_presents?(region, shapes) end,
      max_concurrency: System.schedulers_online(),
      timeout: :infinity
    )
    |> Enum.count(fn {:ok, result} -> result end)
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

    # Pre-compute bounding box for faster bounds checking
    bounds_tuple = {0, width - 1, 0, height - 1}

    %{width: width, height: height, shapes: shapes, bounds_tuple: bounds_tuple}
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

      # Initialize visit counter in process dictionary
      Process.put(:visits, 0)

      # Try to place all presents using backtracking
      result = place_presents(shapes_with_orientations, region, MapSet.new())

      # Clean up process dictionary
      Process.delete(:visits)

      result
    end
  end

  # Backtracking algorithm to place all presents
  defp place_presents([], _region, _occupied), do: true

  defp place_presents([orientations | rest], region, occupied) do
    # Check visit limit using process dictionary
    visits = Process.get(:visits, 0)

    if visits > @max_visits do
      false
    else
      # Increment visit counter
      Process.put(:visits, visits + 1)

      # Get candidate positions (reduce search space)
      candidate_positions = get_smart_positions(region, occupied)

      # Try all orientations
      Enum.any?(orientations, fn oriented_shape ->
        # Try candidate positions only
        Enum.any?(candidate_positions, fn {x, y} ->
          placed_coords = translate_shape(oriented_shape, x, y)

          if can_place?(placed_coords, region, occupied) do
            # Place it and try to place the rest
            new_occupied = MapSet.union(occupied, placed_coords)
            place_presents(rest, region, new_occupied)
          else
            false
          end
        end)
      end)
    end
  end

  # Directions for 8-way adjacency
  @directions [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  # Get smart positions to try - positions adjacent to occupied cells
  defp get_smart_positions(region, occupied) do
    if MapSet.size(occupied) == 0 do
      # First shape: try origin only
      [{0, 0}]
    else
      # Use comprehension for efficiency - single pass instead of flat_map
      candidates =
        for {x, y} <- occupied,
            {dx, dy} <- @directions,
            nx = x + dx,
            ny = y + dy,
            nx >= 0 and nx < region.width and ny >= 0 and ny < region.height,
            not MapSet.member?(occupied, {nx, ny}),
            do: {nx, ny}

      candidates |> Enum.uniq() |> Enum.sort()
    end
  end

  # Generate all 8 possible orientations (4 rotations × 2 flips)
  defp get_all_orientations(shape) do
    # Pre-compute rotations to avoid redundant rotate_90 calls
    r90 = rotate_90(shape)
    r180 = rotate_90(r90)
    r270 = rotate_90(r180)
    flipped = flip_horizontal(shape)
    f90 = rotate_90(flipped)
    f180 = rotate_90(f90)
    f270 = rotate_90(f180)

    # Use MapSet for O(n) deduplication instead of Enum.uniq O(n²)
    [shape, r90, r180, r270, flipped, f90, f180, f270]
    |> MapSet.new()
    |> MapSet.to_list()
  end

  # Rotate 90 degrees clockwise: (x, y) -> (y, -x)
  defp rotate_90(shape) do
    shape
    |> Enum.map(fn {x, y} -> {y, -x} end)
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
    # Single-pass transformation using Enum.into
    Enum.into(shape, MapSet.new(), fn {x, y} -> {x + dx, y + dy} end)
  end

  # Check if a shape can be placed at the given coordinates
  defp can_place?(coords, region, occupied) do
    {min_x, max_x, min_y, max_y} = region.bounds_tuple

    Enum.all?(coords, fn {x, y} ->
      # Must be within bounds (using pre-computed bounds_tuple)
      x >= min_x and x <= max_x and y >= min_y and y <= max_y and
        # Must not overlap with already placed presents
        not MapSet.member?(occupied, {x, y})
    end)
  end
end
