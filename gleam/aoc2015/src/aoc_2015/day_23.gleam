import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/string

type Instruction {
  Half(register: String)
  Triple(register: String)
  Increment(register: String)
  Jump(offset: Int)
  JumpIfEven(register: String, offset: Int)
  JumpIfOne(register: String, offset: Int)
}

fn parse_instruction(str) {
  case str {
    "hlf " <> r -> Half(r)
    "tpl " <> r -> Triple(r)
    "inc " <> r -> Increment(r)
    "jmp " <> offset -> Jump(to_int(offset))
    "jie " <> args -> {
      let assert [r, offset] = string.split(args, ", ")
      JumpIfEven(r, to_int(offset))
    }
    "jio " <> args -> {
      let assert [r, offset] = string.split(args, ", ")
      JumpIfOne(r, to_int(offset))
    }
    _ -> panic
  }
}

fn step(instructions, registers, pointer) {
  case dict.get(instructions, pointer) {
    Error(_) -> registers
    Ok(Half(r)) ->
      registers
      |> dict.upsert(r, fn(v) {
        let assert Some(v) = v
        v / 2
      })
      |> step(instructions, _, pointer + 1)
    Ok(Triple(r)) ->
      registers
      |> dict.upsert(r, fn(v) {
        let assert Some(v) = v
        v * 3
      })
      |> step(instructions, _, pointer + 1)
    Ok(Increment(r)) ->
      registers
      |> dict.upsert(r, fn(v) {
        let assert Some(v) = v
        v + 1
      })
      |> step(instructions, _, pointer + 1)
    Ok(Jump(offset)) -> step(instructions, registers, pointer + offset)
    Ok(JumpIfEven(r, offset)) ->
      case dict.get(registers, r) {
        Ok(n) if n % 2 == 0 -> step(instructions, registers, pointer + offset)
        _ -> step(instructions, registers, pointer + 1)
      }
    Ok(JumpIfOne(r, offset)) ->
      case dict.get(registers, r) {
        Ok(1) -> step(instructions, registers, pointer + offset)
        _ -> step(instructions, registers, pointer + 1)
      }
  }
}

pub fn pt_1(input: String) {
  let instructions =
    input
    |> string.split("\n")
    |> list.index_map(fn(ins, n) { #(n, parse_instruction(ins)) })
    |> dict.from_list

  let registers = [#("a", 0), #("b", 0)] |> dict.from_list

  step(instructions, registers, 0)
  |> dict.get("b")
}

pub fn pt_2(input: String) {
  let instructions =
    input
    |> string.split("\n")
    |> list.index_map(fn(ins, n) { #(n, parse_instruction(ins)) })
    |> dict.from_list

  let registers = [#("a", 1), #("b", 0)] |> dict.from_list

  step(instructions, registers, 0)
  |> dict.get("b")
}

fn to_int(str) {
  let assert Ok(n) = int.parse(str)
  n
}
