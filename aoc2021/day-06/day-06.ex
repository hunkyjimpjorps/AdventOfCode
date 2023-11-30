defmodule Day06 do
  def next_day(state) do
    with one_day_older <- Enum.into(state, %{}, fn {k, v} -> {k - 1, v} end),
         {n, s} <- Map.pop(one_day_older, -1, 0) do
      Map.update(s, 6, n, &(&1 + n))
      |> Map.put(8, n)
    end
  end
end

school =
  with {:ok, data} <- File.read("input.txt") do
    data
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

starting_state = Enum.frequencies(school)

Enum.reduce(
  Enum.to_list(1..80),
  starting_state,
  fn _, acc -> Day06.next_day(acc) end
)
|> Enum.reduce(0, fn {_, v}, acc -> v + acc end)
|> IO.inspect()

Enum.reduce(
  Enum.to_list(1..256),
  starting_state,
  fn _, acc -> Day06.next_day(acc) end
)
|> Enum.reduce(0, fn {_, v}, acc -> v + acc end)
|> IO.inspect()
