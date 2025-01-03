import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Card {
  Card(number: Int, winners: Int)
}

fn numbers_to_set(str: String) -> Set(Int) {
  str
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.values()
  |> set.from_list()
}

fn parse_card(card: String) -> Card {
  let assert Ok(#("Card" <> n_str, rest)) = string.split_once(card, ": ")
  let assert Ok(#(winning_str, has_str)) = string.split_once(rest, " | ")
  let assert Ok(n) = int.parse(string.trim(n_str))

  let winning = numbers_to_set(winning_str)
  let has = numbers_to_set(has_str)
  let winners = set.size(set.intersection(winning, has))

  Card(number: n, winners: winners)
}

fn win_points(n: Int) {
  bool.guard(n < 2, n, fn() { 2 * win_points(n - 1) })
}

pub fn pt_1(input: String) {
  use acc, c <- list.fold(string.split(input, "\n"), 0)
  c
  |> parse_card
  |> fn(c: Card) { win_points(c.winners) }
  |> int.add(acc)
}

fn win_more_cards(cards: List(String), count: Dict(Int, Int)) {
  case cards {
    [] ->
      count
      |> dict.values
      |> int.sum
    [raw_card, ..rest] -> {
      let card = parse_card(raw_card)
      case card.winners {
        0 -> win_more_cards(rest, count)
        n -> win_more_cards(rest, update_counts(n, card, count))
      }
    }
  }
}

fn update_counts(n: Int, card: Card, count: Dict(Int, Int)) -> Dict(Int, Int) {
  let assert Ok(bonus) = dict.get(count, card.number)
  use acc, n <- list.fold(list.range(card.number + 1, card.number + n), count)
  use c <- dict.upsert(acc, n)
  case c {
    Some(i) -> i + bonus
    None -> panic as "won a card that doesn't exist in the card pile"
  }
}

pub fn pt_2(input: String) {
  let cards = string.split(input, "\n")

  let count =
    list.range(1, list.length(cards))
    |> list.map(fn(n) { #(n, 1) })
    |> dict.from_list()

  win_more_cards(cards, count)
}
