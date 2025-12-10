defmodule Aoc.Day10 do
  import Bitwise

  def part1(args) do
    args
    |> clean_input()
    |> Enum.map(&min_button_presses/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> clean_input()
    |> Enum.map(&min_button_presses_joltage/1)
    |> Enum.sum()
  end

  def clean_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Extract indicator light pattern
    [_, indicator] = Regex.run(~r/\[([.#]+)\]/, line)

    # Extract all button wiring groups
    buttons =
      Regex.scan(~r/\(([0-9,]+)\)/, line)
      |> Enum.map(fn [_, nums] -> parse_numbers(nums) end)

    # Extract joltage requirements
    [_, joltages_str] = Regex.run(~r/\{([0-9,]+)\}/, line)
    joltages = parse_numbers(joltages_str)

    %{
      indicator: indicator,
      buttons: buttons,
      joltages: joltages
    }
  end

  defp parse_numbers(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp min_button_presses(machine) do
    target = parse_target(machine.indicator)
    buttons = machine.buttons

    # Try all combinations of buttons (2^n possibilities)
    n = length(buttons)

    0..((1 <<< n) - 1)
    |> Enum.filter(fn combination ->
      applies_to_target?(combination, buttons, target)
    end)
    |> Enum.map(&count_bits/1)
    |> Enum.min()
  end

  defp parse_target(indicator) do
    # Parse target as a MapSet of indices where lights should be ON
    indicator
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char == "#" end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> MapSet.new()
  end

  defp applies_to_target?(combination, buttons, target) do
    result = apply_buttons(combination, buttons)
    result == target
  end

  defp apply_buttons(combination, buttons) do
    # Start with all lights off (empty MapSet)
    buttons
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {button, idx}, lights ->
      if (combination &&& 1 <<< idx) != 0 do
        # This button is pressed, toggle the lights it affects
        Enum.reduce(button, lights, fn light_idx, acc ->
          if MapSet.member?(acc, light_idx) do
            MapSet.delete(acc, light_idx)
          else
            MapSet.put(acc, light_idx)
          end
        end)
      else
        lights
      end
    end)
  end

  defp count_bits(n) do
    # Count number of 1s in binary representation
    Integer.digits(n, 2) |> Enum.sum()
  end

  # Part 2
  defp min_button_presses_joltage(machine) do
    buttons = machine.buttons
    target = machine.joltages

    solve_with_z3(buttons, target)
  end

  defp solve_with_z3(buttons, target) do
    num_buttons = length(buttons)
    num_counters = length(target)

    # Generate SMT-LIB2 format
    smt_content = generate_smt(buttons, target, num_buttons, num_counters)

    # Write to temp file
    temp_file = "/tmp/z3_problem_#{:erlang.unique_integer([:positive])}.smt2"
    File.write!(temp_file, smt_content)

    # Call Z3
    {output, 0} = System.cmd("z3", [temp_file])

    # Parse result
    result = parse_z3_output(output, num_buttons)

    # Cleanup
    File.rm(temp_file)

    result
  end

  defp generate_smt(buttons, target, num_buttons, num_counters) do
    # Declare button press variables
    declarations =
      0..(num_buttons - 1)
      |> Enum.map(fn i -> "(declare-const b#{i} Int)" end)
      |> Enum.join("\n")

    # Non-negative constraints
    non_negative =
      0..(num_buttons - 1)
      |> Enum.map(fn i -> "(assert (>= b#{i} 0))" end)
      |> Enum.join("\n")

    # Counter constraints - each counter must equal its target
    counter_constraints =
      0..(num_counters - 1)
      |> Enum.map(fn counter_idx ->
        # Find all buttons that affect this counter
        button_terms =
          buttons
          |> Enum.with_index()
          |> Enum.filter(fn {button, _} -> counter_idx in button end)
          |> Enum.map(fn {_, button_idx} -> "b#{button_idx}" end)

        target_val = Enum.at(target, counter_idx)

        if length(button_terms) > 0 do
          sum_expr =
            if length(button_terms) == 1 do
              hd(button_terms)
            else
              "(+ #{Enum.join(button_terms, " ")})"
            end

          "(assert (= #{sum_expr} #{target_val}))"
        else
          "(assert (= 0 #{target_val}))"
        end
      end)
      |> Enum.join("\n")

    # Objective: minimize sum of all button presses
    total_presses =
      if num_buttons == 1 do
        "b0"
      else
        button_vars = 0..(num_buttons - 1) |> Enum.map(fn i -> "b#{i}" end) |> Enum.join(" ")
        "(+ #{button_vars})"
      end

    """
    #{declarations}
    #{non_negative}
    #{counter_constraints}
    (minimize #{total_presses})
    (check-sat)
    (get-model)
    """
  end

  defp parse_z3_output(output, num_buttons) do
    # Extract the model values
    values =
      0..(num_buttons - 1)
      |> Enum.map(fn i ->
        case Regex.run(~r/\(define-fun b#{i} \(\) Int\s+(\d+)\)/, output) do
          [_, val] -> String.to_integer(val)
          nil -> 0
        end
      end)

    Enum.sum(values)
  end
end
