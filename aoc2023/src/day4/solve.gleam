import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/int
import gleam/list
import gleam/dict
import gleam/result
import gleam/option.{None, Some}

type Card {
  Card(number: Int, winning: List(Int), has: List(Int))
}

fn numbers_to_list(str: String) -> List(Int) {
  str
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.values()
}

fn parse_card(card: String) -> Card {
  let assert Ok(#("Card" <> n_str, rest)) = string.split_once(card, ": ")
  let assert Ok(#(winning_str, has_str)) = string.split_once(rest, " | ")
  let assert Ok(n) =
    n_str
    |> string.trim
    |> int.parse

  let winning = numbers_to_list(winning_str)
  let has = numbers_to_list(has_str)

  Card(number: n, winning: winning, has: has)
}

fn win_points(n) {
  case n {
    0 -> 0
    1 -> 1
    n -> 2 * win_points(n - 1)
  }
}

fn count_wins(card: Card) {
  use acc, c <- list.fold(card.has, 0)
  case list.contains(card.winning, c) {
    True -> acc + 1
    False -> acc
  }
}

pub fn part1(input: String) {
  use acc, c <- list.fold(string.split(input, "\n"), 0)
  c
  |> parse_card
  |> count_wins
  |> win_points
  |> int.add(acc)
}

fn win_more_cards(cards: List(String), card_count: dict.Dict(Int, Int)) {
  case cards {
    [] ->
      card_count
      |> dict.values
      |> int.sum
    [raw_card, ..rest] -> {
      let card = parse_card(raw_card)
      let wins = count_wins(card)
      case wins {
        0 -> win_more_cards(rest, card_count)
        n -> {
          let assert Ok(bonus) = dict.get(card_count, card.number)
          let won_cards = list.range(card.number + 1, card.number + n)
          {
            use acc, n <- list.fold(won_cards, card_count)
            use c <- dict.update(acc, n)
            case c {
              Some(i) -> i + bonus
              None -> panic as "won a card that doesn't exist in the card pile"
            }
          }
          |> win_more_cards(rest, _)
        }
      }
    }
  }
}

pub fn part2(input: String) {
  let raw_cards =
    input
    |> string.split("\n")

  let card_count =
    list.range(1, list.length(raw_cards))
    |> list.map(fn(n) { #(n, 1) })
    |> dict.from_list()

  raw_cards
  |> win_more_cards(card_count)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("4")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
