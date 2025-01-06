import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import my_utils/to

type Input =
  #(List(#(Int, Node)), Dict(Node, Content))

pub type Node {
  Output(name: String)
  Bot(name: String)
}

pub type Content {
  Bin(contents: List(Int))
  Sorter(
    contents: List(Int),
    low: Node,
    high: Node,
    compared: Option(#(Int, Int)),
  )
}

fn kind(str) {
  case str {
    "bot" -> Bot
    "output" -> Output
    _ -> panic
  }
}

pub fn parse(input: String) -> Input {
  let assert Ok(re) = regexp.from_string("^value (\\d+) goes to bot (\\d+)$")

  let initial =
    input
    |> string.split("\n")
    |> list.filter_map(fn(line) {
      case regexp.scan(re, line) {
        [Match(submatches: [Some(chip), Some(bot)], ..)] ->
          Ok(#(to.int(chip), Bot(bot)))
        _ -> Error(Nil)
      }
    })

  let assert Ok(re) =
    regexp.from_string(
      "^bot (\\d+) gives low to (output|bot) (\\d+) and high to (output|bot) (\\d+)$",
    )

  let bots =
    input
    |> string.split("\n")
    |> list.filter_map(fn(line) {
      case regexp.scan(re, line) {
        [Match(submatches:, ..)] -> {
          let assert [name, kind1, dest1, kind2, dest2] =
            option.values(submatches)
          Ok(#(
            Bot(name),
            Sorter([], kind(kind1)(dest1), kind(kind2)(dest2), None),
          ))
        }
        _ -> Error(Nil)
      }
    })
    |> dict.from_list

  #(initial, bots)
}

fn next_chip(chips, bots) {
  case chips {
    [] -> bots
    [#(chip, dest), ..rest] ->
      case dict.get(bots, dest) {
        Error(Nil) -> dict.insert(bots, dest, Bin([chip])) |> next_chip(rest, _)
        Ok(Bin(contents)) ->
          dict.insert(bots, dest, Bin([chip, ..contents]))
          |> next_chip(rest, _)
        Ok(Sorter([], _, _, _) as sorter) ->
          dict.insert(bots, dest, Sorter(..sorter, contents: [chip]))
          |> next_chip(rest, _)
        Ok(Sorter([prior], low:, high:, ..) as sorter) -> {
          let min = int.min(chip, prior)
          let max = int.max(chip, prior)
          let updated_bots =
            dict.insert(
              bots,
              dest,
              Sorter(..sorter, contents: [], compared: Some(#(min, max))),
            )
          let queue_chips = [#(min, low), #(max, high), ..rest]
          next_chip(queue_chips, updated_bots)
        }
        _ -> panic
      }
  }
}

pub fn pt_1(input: Input) {
  let #(chips, bots) = input

  next_chip(chips, bots)
  |> dict.to_list
  |> list.find_map(fn(b) {
    case b {
      #(Bot(n), Sorter(compared: Some(#(17, 61)), ..)) -> Ok(n)
      _ -> Error(Nil)
    }
  })
  |> result.then(int.parse)
  |> result.unwrap(0)
}

pub fn pt_2(input: Input) {
  let #(chips, bots) = input

  let finished_bots = next_chip(chips, bots)

  list.fold([0, 1, 2], 1, fn(acc, o) {
    let assert Ok(Bin([n])) = dict.get(finished_bots, Output(int.to_string(o)))
    acc * n
  })
}
