pub const template = "
import gleam/list
import gleeunit/should
import adglent.{type Example, Example}
import day{{ day }}/solve

type Problem1AnswerType =
  String

type Problem2AnswerType =
  String

/// Add examples for part 1 here:
/// ```gleam
///const part1_examples: List(Example(Problem1AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part1_examples: List(Example(Problem1AnswerType)) = []

/// Add examples for part 2 here:
/// ```gleam
///const part2_examples: List(Example(Problem2AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part2_examples: List(Example(Problem2AnswerType)) = []

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.not_equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}

"
