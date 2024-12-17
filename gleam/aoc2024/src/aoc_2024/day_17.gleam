import gary.{type ErlangArray}
import gary/array
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import my_utils/math
import my_utils/to

pub type Register {
  Register(
    a: Int,
    b: Int,
    c: Int,
    pointer: Int,
    program: ErlangArray(Int),
    output: List(Int),
  )
}

pub fn parse(input: String) -> Register {
  let assert Ok(register_re) = regexp.from_string("Register .: (\\d+)\n")
  let assert Ok(program_re) = regexp.from_string("Program: (.+)$")

  let assert [a, b, c] =
    regexp.scan(register_re, input)
    |> list.flat_map(fn(m) { option.values(m.submatches) })
    |> list.map(to.int)

  let assert [regexp.Match(submatches: [option.Some(program)], ..)] =
    regexp.scan(program_re, input)
  let program = program |> to.ints(",") |> array.from_list(-1)

  Register(a:, b:, c:, pointer: 0, program:, output: [])
}

fn as_combo(operand: Int, register: Register) -> Int {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> register.a
    5 -> register.b
    6 -> register.c
    _ -> panic
  }
}

fn do_op(instruction: Int, operand: Int, register: Register) {
  case instruction {
    0 ->
      Register(
        ..register,
        a: register.a / math.pow(2, as_combo(operand, register)),
        pointer: register.pointer + 2,
      )
    1 ->
      Register(
        ..register,
        b: int.bitwise_exclusive_or(register.b, operand),
        pointer: register.pointer + 2,
      )
    2 ->
      Register(
        ..register,
        b: as_combo(operand, register) % 8,
        pointer: register.pointer + 2,
      )
    3 ->
      case register.a {
        0 -> Register(..register, pointer: register.pointer + 2)
        _ -> Register(..register, pointer: operand)
      }
    4 ->
      Register(
        ..register,
        b: int.bitwise_exclusive_or(register.b, register.c),
        pointer: register.pointer + 2,
      )
    5 ->
      Register(
        ..register,
        output: [as_combo(operand, register) % 8, ..register.output],
        pointer: register.pointer + 2,
      )
    6 ->
      Register(
        ..register,
        b: register.a / math.pow(2, as_combo(operand, register)),
        pointer: register.pointer + 2,
      )
    7 ->
      Register(
        ..register,
        c: register.a / math.pow(2, as_combo(operand, register)),
        pointer: register.pointer + 2,
      )
    _ -> panic
  }
}

fn run_program(register: Register) {
  let Register(pointer:, program:, output:, ..) = register
  let op = array.get(program, pointer)
  let operand = array.get(program, pointer + 1)

  case op, operand {
    Ok(-1), _ | _, Ok(-1) -> output |> list.reverse
    Ok(op), Ok(operand) -> do_op(op, operand, register) |> run_program
    _, _ -> panic
  }
}

pub fn pt_1(input: Register) {
  run_program(input)
  |> list.map(int.to_string)
  |> string.join(",")
}

fn is_prefix_of(prefix: List(a), source: List(a)) {
  case prefix, source {
    [], _ -> True
    [a, ..a_rest], [b, ..b_rest] if a == b -> is_prefix_of(a_rest, b_rest)
    _, _ -> False
  }
}

fn search_for_a(goal, acc, register) {
  case acc {
    [] -> Error(Nil)
    [#(next, result), ..rest] -> {
      case result == goal {
        True -> Ok(next)
        False -> {
          list.range(0, 7)
          |> list.filter_map(fn(n) {
            let trial_a = next * 8 + n
            let trial_quine =
              Register(..register, a: trial_a)
              |> run_program
              |> list.reverse
            case is_prefix_of(trial_quine, goal) {
              True -> Ok(#(trial_a, trial_quine))
              False -> Error(Nil)
            }
          })
          |> list.append(rest)
          |> search_for_a(goal, _, register)
        }
      }
    }
  }
}

pub fn pt_2(input: Register) {
  input.program
  |> array.to_list
  |> list.reverse
  |> search_for_a([#(0, [])], input)
}
