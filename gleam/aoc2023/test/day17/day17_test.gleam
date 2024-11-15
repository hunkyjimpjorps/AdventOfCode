import adglent.{type Example, Example}
import day17/solve
import gleam/list
import gleeunit/should

type Problem1AnswerType =
  String

// type Problem2AnswerType =
//   String

/// Add examples for part 1 here:
/// ```gleam
///const part1_examples: List(Example(Problem1AnswerType)) = [Example("some input", "")]
/// ```
const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533",
    "102",
  ),
]

// /// ```
// const part2_examples: List(Example(Problem2AnswerType)) = []

/// Add examples for part 2 here:
/// ```gleam
///const part2_examples: List(Example(Problem2AnswerType)) = [Example("some input", "")]
pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}
// pub fn part2_test() {
//   part2_examples
//   |> should.not_equal([])
//   use example <- list.map(part2_examples)
//   solve.part2(example.input)
//   |> should.equal(example.answer)
// }
