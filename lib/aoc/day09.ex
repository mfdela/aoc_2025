defmodule Aoc.Day09 do
  def part1(args) do
    args
    |> clean_input()
    |> largest_rectangle_two_corners()
    |> elem(2)
  end

  def part2(args) do
    red_tiles =
      args
      |> clean_input()

    largest_rectangle(red_tiles)
    |> elem(4)
  end

  def clean_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  def largest_rectangle_two_corners(red_tiles) do
    red_tiles
    |> Enum.flat_map(fn {x1, y1} = tile1 ->
      Enum.map(red_tiles, fn {x2, y2} = tile2 ->
        {tile1, tile2, abs(x2 - x1 + 1) * abs(y2 - y1 + 1)}
      end)
    end)
    |> Enum.max_by(fn {_, _, area} -> area end)
  end

  @doc """
  Find largest rectangle with opposite corners at polygon vertices.
  A rectangle is valid if no polygon edge passes through its interior.
  """
  def largest_rectangle(polygon) do
    edges = build_edges(polygon)

    polygon
    |> pairs_of_opposite_corners()
    |> Enum.filter(fn {x1, y1, x2, y2, _area} ->
      rectangle_valid?(x1, y1, x2, y2, edges)
    end)
    |> Enum.max_by(fn {_, _, _, _, area} -> area end, fn -> nil end)
  end

  defp pairs_of_opposite_corners(polygon) do
    for {x1, y1} <- polygon,
        {x2, y2} <- polygon,
        x1 < x2,
        y1 != y2 do
      # Normalize so we always have y_lo < y_hi for the rectangle
      {y_lo, y_hi} = if y1 < y2, do: {y1, y2}, else: {y2, y1}
      area = (x2 - x1 + 1) * (y_hi - y_lo + 1)
      {x1, y_lo, x2, y_hi, area}
    end
  end

  defp build_edges(polygon) do
    polygon
    |> Enum.chunk_every(2, 1, [List.first(polygon)])
    |> Enum.map(fn [{x1, y1}, {x2, y2}] -> {x1, y1, x2, y2} end)
  end

  defp rectangle_valid?(rx1, ry1, rx2, ry2, edges) do
    # A rectangle is invalid if any polygon edge:
    # 1. Has its midpoint strictly inside the rectangle, OR
    # 2. Crosses any of the rectangle's boundary edges
    not Enum.any?(edges, fn {ex1, ey1, ex2, ey2} ->
      edge_passes_through_rect?(ex1, ey1, ex2, ey2, rx1, ry1, rx2, ry2) or
        edge_crosses_rect_boundary?(ex1, ey1, ex2, ey2, rx1, ry1, rx2, ry2)
    end)
  end

  # Check if a line segment passes through the strict interior of a rectangle
  defp edge_passes_through_rect?(ex1, ey1, ex2, ey2, rx1, ry1, rx2, ry2) do
    # Check if midpoint of edge is strictly inside rectangle
    mid_x = (ex1 + ex2) / 2
    mid_y = (ey1 + ey2) / 2

    mid_x > rx1 and mid_x < rx2 and mid_y > ry1 and mid_y < ry2
  end

  # Check if edge crosses any of the 4 rectangle boundary lines
  defp edge_crosses_rect_boundary?(ex1, ey1, ex2, ey2, rx1, ry1, rx2, ry2) do
    rect_edges = [
      # bottom
      {rx1, ry1, rx2, ry1},
      # top
      {rx1, ry2, rx2, ry2},
      # left
      {rx1, ry1, rx1, ry2},
      # right
      {rx2, ry1, rx2, ry2}
    ]

    Enum.any?(rect_edges, fn {bx1, by1, bx2, by2} ->
      segments_cross?(ex1, ey1, ex2, ey2, bx1, by1, bx2, by2)
    end)
  end

  defp segments_cross?(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2) do
    d1 = direction(bx1, by1, bx2, by2, ax1, ay1)
    d2 = direction(bx1, by1, bx2, by2, ax2, ay2)
    d3 = direction(ax1, ay1, ax2, ay2, bx1, by1)
    d4 = direction(ax1, ay1, ax2, ay2, bx2, by2)
    d1 * d2 < 0 and d3 * d4 < 0
  end

  defp direction(x1, y1, x2, y2, x3, y3) do
    (x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1)
  end
end
