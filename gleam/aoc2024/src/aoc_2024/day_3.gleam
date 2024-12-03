import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match, Match}
import my_utils/to

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  regexp.scan(with: re, content: input)
  |> list.fold(0, fn(acc, match) {
    let assert Match(_, [Some(a), Some(b)]) = match
    acc + to.int(a) * to.int(b)
  })
}

pub fn pt_2(input: String) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\)")
  input
  |> regexp.scan(with: re)
  |> evaluate_instructions(0, True)
}

fn evaluate_instructions(instructions: List(Match), acc: Int, doing: Bool) {
  case instructions, doing {
    [], _ -> acc
    [Match("don't()", []), ..rest], _ -> evaluate_instructions(rest, acc, False)
    [Match("do()", []), ..rest], _ -> evaluate_instructions(rest, acc, True)
    [Match(_, [Some(a), Some(b)]), ..rest], True ->
      evaluate_instructions(rest, acc + to.int(a) * to.int(b), True)
    [_, ..rest], False -> evaluate_instructions(rest, acc, False)
    _, _ -> panic as "unexpected match"
  }
}
