import adglent.{First, Second}
import gleam/bool
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order, Eq, Lt}
import gleam/string

// Types -------------------------------------------------------------------------------------------

type Hand {
  Hand(cards: List(Int), wager: Int)
}

type HandType {
  FiveOfAKind
  FourOfAKind
  FullHouse
  ThreeOfAKind
  TwoPair
  OnePair
  HighCard
  Unknown
}

// Common functions --------------------------------------------------------------------------------

fn hand_rank(hand_rank: HandType) -> Int {
  case hand_rank {
    HighCard -> 1
    OnePair -> 2
    TwoPair -> 3
    ThreeOfAKind -> 4
    FullHouse -> 5
    FourOfAKind -> 6
    FiveOfAKind -> 7
    Unknown -> 100
  }
}

fn card_rank(card: String) -> Int {
  case int.parse(card), card {
    Ok(n), _ -> n
    _, "A" -> 14
    _, "K" -> 13
    _, "Q" -> 12
    _, "J" -> 11
    _, "T" -> 10
    _, "*" -> 1
  }
}

fn parse_hand(str: String) -> Hand {
  let [cards, wager] = string.split(str, " ")
  let cards =
    string.to_graphemes(cards)
    |> list.map(card_rank)
  let assert Ok(wager) = int.parse(wager)

  Hand(cards, wager)
}

fn card_counts(hand: Hand) {
  hand.cards
  |> list.sort(int.compare)
  |> list.chunk(function.identity)
  |> list.map(list.length)
  |> list.sort(int.compare)
}

fn classify_hand(hand: Hand) -> HandType {
  case list.length(list.unique(hand.cards)), card_counts(hand) {
    1, _ -> FiveOfAKind
    2, [1, 4] -> FourOfAKind
    2, [2, 3] -> FullHouse
    3, [1, 1, 3] -> ThreeOfAKind
    3, [1, 2, 2] -> TwoPair
    4, _ -> OnePair
    5, _ -> HighCard
    _, _ -> Unknown
  }
}

// Part 1 ------------------------------------------------------------------------------------------

pub fn part1(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_hand)
  |> list.sort(compare_hands)
  |> list.index_map(fn(i, h) { { i + 1 } * h.wager })
  |> int.sum
  |> string.inspect
}

fn compare_hands(hand1: Hand, hand2: Hand) -> Order {
  case
    int.compare(
      hand_rank(classify_hand(hand1)),
      hand_rank(classify_hand(hand2)),
    )
  {
    Eq -> compare_top_card(hand1.cards, hand2.cards)
    other -> other
  }
}

fn compare_top_card(cards1: List(Int), cards2: List(Int)) -> Order {
  use <- bool.guard(cards1 == [] || cards2 == [], Eq)
  let [c1, ..rest1] = cards1
  let [c2, ..rest2] = cards2
  case int.compare(c1, c2) {
    Eq -> compare_top_card(rest1, rest2)
    other -> other
  }
}

// Part 2 ------------------------------------------------------------------------------------------

pub fn part2(input: String) {
  input
  |> string.replace("J", "*")
  |> string.split("\n")
  |> list.map(parse_hand)
  |> list.sort(compare_hands_considering_jokers)
  |> list.index_map(fn(i, h) { { i + 1 } * h.wager })
  |> int.sum
  |> string.inspect
}

const card_subs = [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]

fn find_best_joker_substitution(hand: Hand) {
  use acc, card <- list.fold(card_subs, Hand([2, 3, 4, 5, 6], 0))
  let subbed_cards =
    list.map(
      hand.cards,
      fn(c) {
        case c {
          1 -> card
          other -> other
        }
      },
    )
  let subbed_hand = Hand(..hand, cards: subbed_cards)
  case compare_hands(acc, subbed_hand) {
    Lt -> subbed_hand
    _ -> acc
  }
}

fn compare_hands_considering_jokers(hand1: Hand, hand2: Hand) -> Order {
  case
    int.compare(
      hand1
      |> find_best_joker_substitution
      |> classify_hand
      |> hand_rank,
      hand2
      |> find_best_joker_substitution
      |> classify_hand
      |> hand_rank,
    )
  {
    Eq -> compare_top_card(hand1.cards, hand2.cards)
    other -> other
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("7")
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
