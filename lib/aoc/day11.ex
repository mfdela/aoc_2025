defmodule Aoc.Day11 do
  def part1(args) do
    args
    |> clean_input()
    |> Graph.get_paths("you", "out")
    |> Enum.count()
  end

  def part2(args) do
    args
    |> clean_input()
    |> count_paths_through_two_nodes("svr", "out", "dac", "fft")
  end

  def clean_input(input) do
    g = Graph.new(type: :directed)

    for line <- String.split(input, "\n", trim: true), reduce: g do
      acc ->
        [from, to] = String.split(line, ": ")
        Graph.add_vertex(acc, from)

        for dest <- String.split(to, " ", trim: true), reduce: acc do
          inner_acc -> Graph.add_edge(inner_acc, from, dest)
        end
    end
  end

  def count_paths_through_two_nodes(graph, start, out, node_a, node_b) do
    # Case 1: start → A → B → out
    count1 =
      elem(count_dag_paths(graph, start, node_a), 0) *
        elem(count_dag_paths(graph, node_a, node_b), 0) *
        elem(count_dag_paths(graph, node_b, out), 0)

    count2 =
      elem(count_dag_paths(graph, start, node_b), 0) *
        elem(count_dag_paths(graph, node_b, node_a), 0) *
        elem(count_dag_paths(graph, node_a, out), 0)

    count1 + count2
  end

  def count_dag_paths(graph, source, target, memo \\ %{}) do
    cond do
      source == target ->
        {1, memo}

      Map.has_key?(memo, {source, target}) ->
        {Map.get(memo, {source, target}), memo}

      true ->
        neighbors = Graph.out_neighbors(graph, source)

        {total, memo} =
          Enum.reduce(neighbors, {0, memo}, fn neighbor, {count, m} ->
            {n_count, new_m} = count_dag_paths(graph, neighbor, target, m)
            {count + n_count, new_m}
          end)

        memo = Map.put(memo, {source, target}, total)
        {total, memo}
    end
  end
end
