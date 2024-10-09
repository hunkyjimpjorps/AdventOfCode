import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

const max_register = "__MAX"

pub type Instruction {
  Instruction(register: String, op: Operation, condition: Condition)
}

pub type Operation {
  Inc(by: Int)
  Dec(by: Int)
}

pub type Condition {
  Equal(register: String, value: Int)
  NotEqual(register: String, value: Int)
  LessThan(register: String, value: Int)
  GreaterThan(register: String, value: Int)
  LessThanOrEq(register: String, value: Int)
  GreaterThanOrEq(register: String, value: Int)
}

type Registers =
  dict.Dict(String, Int)

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_instruction)
}

fn parse_instruction(str: String) -> Instruction {
  case string.split(str, " ") {
    [name, op, by, "if", cond_name, cond_type, cond_by] ->
      Instruction(name, to_op(op, by), to_cond(cond_name, cond_type, cond_by))
    _ -> panic as { "couldn't parse: " <> str }
  }
}

pub fn pt_1(input: List(Instruction)) {
  let registers = dict.new() |> dict.insert(max_register, 0)

  input
  |> list.fold(registers, next_instruction)
  |> dict.delete(max_register)
  |> dict.values()
  |> list.reduce(int.max)
}

fn next_instruction(regs: Registers, inst: Instruction) {
  case to_compare_fn(inst.condition)(fetch(inst.condition.register, regs)) {
    True -> {
      let updated_regs = dict.update(regs, inst.register, to_update_fn(inst.op))
      let assert Ok(max) = updated_regs |> dict.values |> list.reduce(int.max)
      dict.insert(updated_regs, max_register, max)
    }
    False -> regs
  }
}

pub fn pt_2(input: List(Instruction)) {
  let registers = dict.new() |> dict.insert(max_register, 0)

  input
  |> list.fold(registers, next_instruction)
  |> dict.get(max_register)
}

fn int(str: String) -> Int {
  let assert Ok(n) = int.parse(str)
  n
}

fn to_op(raw_op: String, raw_by: String) -> Operation {
  case raw_op {
    "inc" -> Inc(int(raw_by))
    "dec" -> Dec(int(raw_by))
    _ -> panic as { "bad op: " <> raw_op }
  }
}

fn to_cond(name: String, raw_type: String, raw_by: String) -> Condition {
  case raw_type {
    "==" -> Equal(name, int(raw_by))
    "!=" -> NotEqual(name, int(raw_by))
    ">" -> GreaterThan(name, int(raw_by))
    "<" -> LessThan(name, int(raw_by))
    ">=" -> GreaterThanOrEq(name, int(raw_by))
    "<=" -> LessThanOrEq(name, int(raw_by))
    _ -> panic as { "bad condition: " <> raw_type }
  }
}

fn to_compare_fn(condition: Condition) -> fn(Int) -> Bool {
  case condition {
    Equal(value: v, ..) -> fn(a) { a == v }
    NotEqual(value: v, ..) -> fn(a) { a != v }
    GreaterThan(value: v, ..) -> fn(a) { a > v }
    LessThan(value: v, ..) -> fn(a) { a < v }
    GreaterThanOrEq(value: v, ..) -> fn(a) { a >= v }
    LessThanOrEq(value: v, ..) -> fn(a) { a <= v }
  }
}

fn to_update_fn(op: Operation) {
  case op {
    Inc(n) -> fn(x) {
      case x {
        Some(i) -> i + n
        None -> n
      }
    }
    Dec(n) -> fn(x) {
      case x {
        Some(i) -> i - n
        None -> -n
      }
    }
  }
}

fn fetch(name: String, registers: Registers) -> Int {
  case dict.get(registers, name) {
    Ok(n) -> n
    Error(_) -> 0
  }
}
