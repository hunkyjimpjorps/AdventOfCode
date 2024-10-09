import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type DanceMove {
  Spin(moving: Int)
  Exchange(first: Int, second: Int)
  Partner(first: String, second: String)
}

const initial_lineup = "abcdefghijklmnop"

const dancer_count = 16

const end_state = 1_000_000_000

pub fn parse(input: String) {
  string.split(input, ",")
}

fn do_spin(dancers: List(String), moving: Int) {
  let #(front, back) = list.split(dancers, dancer_count - moving)
  list.append(back, front)
}

fn do_exchange(dancers: List(String), first: Int, second: Int) {
  let indexed = list.index_map(dancers, fn(d, i) { #(i, d) })

  let assert Ok(first_dancer) = list.key_find(indexed, first)
  let assert Ok(second_dancer) = list.key_find(indexed, second)

  indexed
  |> list.key_set(first, second_dancer)
  |> list.key_set(second, first_dancer)
  |> list.map(fn(tup) { tup.1 })
}

fn do_partner(dancers: List(String), first: String, second: String) {
  use dancer <- list.map(dancers)
  case dancer {
    d if d == first -> second
    d if d == second -> first
    d -> d
  }
}

pub fn pt_1(input: List(String)) {
  initial_lineup
  |> string.to_graphemes()
  |> next_move(input)
  |> string.concat()
}

fn next_move(dancers, raw_moves) {
  case raw_moves {
    [] -> dancers
    ["s" <> size, ..rest] -> dancers |> do_spin(int(size)) |> next_move(rest)
    ["x" <> swap, ..rest] -> {
      let assert Ok(#(first, second)) = string.split_once(swap, "/")
      dancers |> do_exchange(int(first), int(second)) |> next_move(rest)
    }
    ["p" <> swap, ..rest] -> {
      let assert Ok(#(first, second)) = string.split_once(swap, "/")
      dancers |> do_partner(first, second) |> next_move(rest)
    }
    _ -> panic as "bad dance move"
  }
}

pub fn pt_2(input: List(String)) {
  initial_lineup
  |> string.to_graphemes()
  |> find_cycle(caching_in: dict.new(), cycle: 0, dancing_to: input)
}

fn find_cycle(
  moving_to dance_position: List(String),
  caching_in cache: Dict(String, Int),
  cycle cycle: Int,
  dancing_to dance_moves: List(String),
) {
  let dance_hash = string.concat(dance_position)
  case dict.get(cache, dance_hash) {
    Ok(c) -> {
      let offset = end_state % { cycle - c } - c
      let assert [#(final, _)] =
        dict.filter(cache, fn(_, v) { v == offset }) |> dict.to_list()
      final
    }
    _err ->
      find_cycle(
        moving_to: next_move(dance_position, dance_moves),
        caching_in: dict.insert(cache, dance_hash, cycle),
        cycle: cycle + 1,
        dancing_to: dance_moves,
      )
  }
}

fn int(n) {
  let assert Ok(n) = int.parse(n)
  n
}
