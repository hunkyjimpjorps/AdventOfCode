import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Lt}
import gleam/string

type Hand {
  Hand(cards: List(Int), wager: Int)
}

fn parse_hand(str: String) -> Hand {
  let assert [cards, wager] = string.split(str, " ")
  let cards =
    string.to_graphemes(cards)
    |> list.map(card_rank)
  let assert Ok(wager) = int.parse(wager)

  Hand(cards, wager)
}

fn classify_hand(hand: Hand) -> Int {
  case list.length(list.unique(hand.cards)), card_counts(hand) {
    1, _ -> 8
    2, [1, 4] -> 7
    2, [2, 3] -> 6
    3, [1, 1, 3] -> 5
    3, [1, 2, 2] -> 4
    4, _ -> 3
    5, _ -> 2
    _, _ -> 1
  }
}

fn card_counts(hand: Hand) {
  hand.cards
  |> list.sort(int.compare)
  |> list.chunk(function.identity)
  |> list.map(list.length)
  |> list.sort(int.compare)
}

fn card_rank(card: String) -> Int {
  case int.parse(card), card {
    Ok(n), _ -> n
    _, "A" -> 14
    _, "K" -> 13
    _, "Q" -> 12
    _, "J" -> 11
    _, "T" -> 10
    _, _ -> 1
  }
}

fn compare_hands(hand1: Hand, hand2: Hand, using: fn(Hand) -> Int) -> Order {
  case int.compare(using(hand1), using(hand2)) {
    Eq -> compare_top_card(hand1.cards, hand2.cards)
    other -> other
  }
}

fn compare_top_card(cards1: List(Int), cards2: List(Int)) -> Order {
  use <- bool.guard(cards1 == [] || cards2 == [], Eq)
  let assert [c1, ..rest1] = cards1
  let assert [c2, ..rest2] = cards2
  case int.compare(c1, c2) {
    Eq -> compare_top_card(rest1, rest2)
    other -> other
  }
}

fn solve(input: String, comparator: fn(Hand, Hand) -> Order) {
  input
  |> string.split("\n")
  |> list.map(parse_hand)
  |> list.sort(comparator)
  |> list.index_map(fn(h, i) { { i + 1 } * h.wager })
  |> int.sum
}

fn compare_without_wilds(hand1: Hand, hand2: Hand) {
  compare_hands(hand1, hand2, classify_hand)
}

pub fn pt_1(input: String) {
  solve(input, compare_without_wilds)
}

fn find_best_joker_substitution(hand: Hand) {
  use acc, card <- list.fold(list.range(2, 14), Hand([], 0))
  let subbed_cards = {
    use c <- list.map(hand.cards)
    case c {
      1 -> card
      other -> other
    }
  }
  let subbed_hand = Hand(..hand, cards: subbed_cards)
  case compare_hands(acc, subbed_hand, classify_hand) {
    Lt -> subbed_hand
    _ -> acc
  }
}

fn compare_hands_considering_jokers(hand1: Hand, hand2: Hand) -> Order {
  use hand <- compare_hands(hand1, hand2)
  hand
  |> find_best_joker_substitution
  |> classify_hand
}

pub fn pt_2(input: String) {
  solve(string.replace(input, "J", "*"), compare_hands_considering_jokers)
}
