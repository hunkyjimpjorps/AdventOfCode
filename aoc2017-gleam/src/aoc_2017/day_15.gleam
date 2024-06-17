import gleam/int
import gleam/string

const sixteen_bits = 0xFFFF

const generator_a = 16_807

const generator_b = 48_271

const divisor = 2_147_483_647

const max_reps_pt1 = 40_000_000

const max_reps_pt2 = 5_000_000

pub fn parse(input: String) {
  let assert Ok(#(a_str, b_str)) = string.split_once(input, ",")
  let assert Ok(a) = int.parse(a_str)
  let assert Ok(b) = int.parse(b_str)

  #(a, b)
}

pub fn pt_1(input: #(Int, Int)) {
  let #(a, b) = input

  next_comparison(
    a: a,
    b: b,
    selecting_a_using: next_value,
    selecting_b_using: next_value,
    initial_matches: 0,
    initial_cycle: 0,
    up_to: max_reps_pt1,
  )
}

pub fn pt_2(input: #(Int, Int)) {
  let #(a, b) = input

  next_comparison(
    a: a,
    b: b,
    selecting_a_using: next_but_divisible_by(4),
    selecting_b_using: next_but_divisible_by(8),
    initial_matches: 0,
    initial_cycle: 0,
    up_to: max_reps_pt2,
  )
}

fn next_value(current, generator) {
  { current * generator } % divisor
}

fn picky_generator(current, generator, divisible_by) {
  let trial = next_value(current, generator)
  case trial % divisible_by {
    0 -> trial
    _ -> picky_generator(trial, generator, divisible_by)
  }
}

fn next_but_divisible_by(divisible_by) {
  fn(c, g) { picky_generator(c, g, divisible_by) }
}

fn last_16_bits(n: Int) {
  int.bitwise_and(n, sixteen_bits)
}

fn next_comparison(
  a a: Int,
  b b: Int,
  selecting_a_using for_a: fn(Int, Int) -> Int,
  selecting_b_using for_b: fn(Int, Int) -> Int,
  initial_matches same: Int,
  initial_cycle count: Int,
  up_to max: Int,
) {
  case count == max {
    True -> same
    False -> {
      let next_a = for_a(a, generator_a)
      let next_b = for_b(b, generator_b)
      let maybe_same = case last_16_bits(next_a) == last_16_bits(next_b) {
        True -> same + 1
        False -> same
      }
      next_comparison(next_a, next_b, for_a, for_b, maybe_same, count + 1, max)
    }
  }
}
