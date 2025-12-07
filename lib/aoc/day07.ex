defmodule Aoc.Day07 do
  def part1(args) do
    grid =
      args
      |> clean_input()

    # Start with beam at start position
    initial_beams = MapSet.new([grid.start])

    process_beams(initial_beams, grid.splitters, grid.rows, grid.cols, MapSet.new([]))
    |> Enum.count()
  end

  def part2(args) do
    grid =
      args
      |> clean_input()

    {x, y} = grid.start

    # Start with beam at start position
    {count, _cache} =
      count_timelines_from(
        x,
        y,
        grid.splitters,
        grid.rows,
        grid.cols,
        %{}
      )

    count
  end

  def clean_input(input) do
    lines = String.split(input, "\n", trim: true)

    rows = length(lines)
    cols = lines |> List.first() |> String.length()

    {splitters, start} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), nil}, fn {line, y}, {split_acc, start_acc} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({split_acc, start_acc}, fn {char, x}, {split, start} ->
          case char do
            "^" -> {MapSet.put(split, {x, y}), start}
            "S" -> {split, {x, y}}
            _ -> {split, start}
          end
        end)
      end)

    %{
      splitters: splitters,
      start: start,
      rows: rows,
      cols: cols
    }
  end

  defp process_beams(beams, splitters, rows, cols, splitters_hit) do
    if MapSet.size(beams) == 0 do
      splitters_hit
    else
      # For each beam, find the next splitter it hits
      {new_beams, new_splits} =
        beams
        |> Enum.reduce({MapSet.new(), splitters_hit}, fn {x, y}, {acc_beams, acc_splits} ->
          case find_next_splitter(x, y + 1, splitters, rows) do
            nil ->
              # Beam exits the manifold
              {acc_beams, acc_splits}

            {split_x, split_y} ->
              # Hit a splitter - create beams to left and right

              new_positions =
                [
                  {split_x - 1, split_y},
                  {split_x + 1, split_y}
                ]
                |> Enum.filter(fn {beam_x, _} -> beam_x >= 0 && beam_x < cols end)

              {MapSet.union(acc_beams, MapSet.new(new_positions)),
               MapSet.union(acc_splits, MapSet.new([{split_x, split_y}]))}
          end
        end)

      process_beams(new_beams, splitters, rows, cols, new_splits)
    end
  end

  defp find_next_splitter(x, y, splitters, rows) do
    cond do
      y >= rows -> nil
      MapSet.member?(splitters, {x, y}) -> {x, y}
      true -> find_next_splitter(x, y + 1, splitters, rows)
    end
  end

  defp count_timelines_from(x, y, splitters, rows, cols, cache) do
    cache_key = {x, y}

    case Map.get(cache, cache_key) do
      nil ->
        # Mark as computing to detect cycles
        cache = Map.put(cache, cache_key, :computing)

        # Find next splitter
        case find_next_splitter(x, y + 1, splitters, rows) do
          nil ->
            # Beam exits - one timeline completes
            cache = Map.put(cache, cache_key, 1)
            {1, cache}

          {split_x, split_y} ->
            # Hit a splitter - branch left and right
            new_positions =
              [
                {split_x - 1, split_y},
                {split_x + 1, split_y}
              ]
              |> Enum.filter(fn {beam_x, _} -> beam_x >= 0 && beam_x < cols end)

            # Sum timelines from both branches
            {total_count, final_cache} =
              new_positions
              |> Enum.reduce({0, cache}, fn {beam_x, beam_y}, {acc_count, acc_cache} ->
                {branch_count, new_cache} =
                  count_timelines_from(beam_x, beam_y, splitters, rows, cols, acc_cache)

                {acc_count + branch_count, new_cache}
              end)

            # Cache the total count from this position
            final_cache = Map.put(final_cache, cache_key, total_count)
            {total_count, final_cache}
        end

      :computing ->
        # Cycle detected - no timelines
        {0, cache}

      cached_count ->
        # Return cached count
        {cached_count, cache}
    end
  end
end
