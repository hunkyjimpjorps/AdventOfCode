defmodule Day02 do
  def part_one(data) do
    data
    |> Enum.reduce(%{pos: 0, dep: 0}, &method_one/2)
    |> get_answer()
  end

  def part_two(data) do
    data
    |> Enum.reduce(%{pos: 0, dep: 0, aim: 0}, &method_two/2)
    |> get_answer()
  end

  defp method_one({:forward, x}, s), do: %{s | pos: s.pos + x}
  defp method_one({:up, x}, s), do: %{s | dep: s.dep - x}
  defp method_one({:down, x}, s), do: %{s | dep: s.dep + x}

  defp method_two({:forward, x}, s), do: %{s | pos: s.pos + x, dep: s.dep + s.aim * x}
  defp method_two({:up, x}, s), do: %{s | aim: s.aim - x}
  defp method_two({:down, x}, s), do: %{s | aim: s.aim + x}

  defp get_answer(s), do: s.pos * s.dep
end

data =
  File.read!("day-02/input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [dir, amt] -> {String.to_atom(dir), String.to_integer(amt)} end)

Day02.part_one(data) |> IO.inspect()
Day02.part_two(data) |> IO.inspect()
