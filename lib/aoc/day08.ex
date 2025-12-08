defmodule Aoc.Day08 do
  def part1(args) do
    {ordered_points, circuits} = process_input(args)

    find_circuits(Enum.take(ordered_points, 1000), circuits)
    |> process_output()
  end

  def part2(args) do
    {ordered_points, circuits} = process_input(args)

    {x1, x2} =
      find_one_circuit(ordered_points, circuits)

    elem(x1, 0) * elem(x2, 0)
  end

  def process_input(input) do
    points =
      input
      |> clean_input()

    ordered_points = order_by_distance(points)

    circuits = create_circuits(points)
    {ordered_points, circuits}
  end

  def process_output(set_list) do
    set_list
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp clean_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [x, y, z] ->
      {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
    end)
  end

  defp straight_line_distance({x1, y1, z1}, {x2, y2, z2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2))
  end

  defp combinations(_, 0), do: [[]]
  defp combinations([], _m), do: []

  defp combinations([h | t], m) do
    for(rest <- combinations(t, m - 1), do: [h | rest]) ++
      combinations(t, m)
  end

  defp order_by_distance(points) do
    for [p1, p2] <- combinations(points, 2), reduce: [] do
      acc ->
        d = straight_line_distance(p1, p2)
        [{d, Enum.sort([p1, p2])} | acc]
    end
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end

  defp create_circuits(points) do
    Enum.reduce(points, [], fn point, acc ->
      [MapSet.new([point]) | acc]
    end)
  end

  def find_circuits(ordered_points, circuits) do
    for [p1, p2] <- ordered_points, reduce: circuits do
      acc ->
        connect_circuits(acc, p1, p2)
    end
  end

  defp find_one_circuit(ordered_points, circuits) do
    Enum.reduce_while(ordered_points, circuits, fn [p1, p2], acc ->
      new_circuits = connect_circuits(acc, p1, p2)

      case length(new_circuits) do
        1 -> {:halt, {p1, p2}}
        _ -> {:cont, new_circuits}
      end
    end)
  end

  defp connect_circuits(circuits, p1, p2) do
    c = MapSet.new([p1, p2])
    # IO.puts("")
    # IO.inspect(c, label: "c")
    # IO.inspect(circuits, label: "circuits")

    circuits_with_index = Enum.with_index(circuits)

    intersects =
      Enum.reject(circuits_with_index, &MapSet.disjoint?(elem(&1, 0), c))

    case intersects do
      [{set, index}] ->
        [MapSet.union(c, set) | List.delete_at(circuits, index)]

      [{set1, index1}, {set2, index2}] ->
        [
          MapSet.union(set1, set2) |> MapSet.union(c)
          | Enum.reject(circuits_with_index, fn {_, idx} -> idx in [index1, index2] end)
            |> Enum.map(&elem(&1, 0))
        ]

      _ ->
        :error
    end
  end
end
