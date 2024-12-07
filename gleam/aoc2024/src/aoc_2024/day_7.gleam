import gleam/int
import gleam/list
import gleam/string
import my_utils/to

pub type Problem {
  Problem(answer: Int, parts: List(Int))
}

pub type Op {
  Add
  Multiply
  Concatenate
}

pub fn parse(input: String) -> List(Problem) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(answer, parts)) = string.split_once(line, ": ")
  let answer = to.int(answer)
  let parts = to.ints(parts, " ")

  Problem(answer:, parts:)
}

fn do_op(op, a, b) {
  case op {
    Add -> a + b
    Multiply -> a * b
    Concatenate -> concatenate(a, b)
  }
}

fn concatenate(a: Int, b: Int) -> Int {
  let assert Ok(a_digits) = int.digits(a, 10)
  let assert Ok(b_digits) = int.digits(b, 10)
  let assert Ok(result) = list.append(a_digits, b_digits) |> int.undigits(10)
  result
}

fn check_problem(problem: Problem, ops: List(Op)) -> Result(Int, Nil) {
  case problem {
    Problem(answer, [a]) if a == answer -> Ok(a)
    Problem(answer, [a, b, ..rest]) -> {
      list.find_map(ops, fn(op) {
        let parts = [do_op(op, a, b), ..rest]
        check_problem(Problem(answer:, parts:), ops)
      })
    }
    _ -> Error(Nil)
  }
}

fn add_up_true_equations(input, operators) {
  use acc, problem <- list.fold(input, 0)
  case check_problem(problem, operators) {
    Ok(n) -> n + acc
    _ -> acc
  }
}

pub fn pt_1(input: List(Problem)) {
  add_up_true_equations(input, [Add, Multiply])
}

pub fn pt_2(input: List(Problem)) {
  add_up_true_equations(input, [Add, Multiply, Concatenate])
}
