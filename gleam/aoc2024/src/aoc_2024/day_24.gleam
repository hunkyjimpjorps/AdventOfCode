import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string

type Input =
  #(Dict(String, Bool), Dict(String, Op))

pub type Op {
  And(left: String, right: String)
  Or(left: String, right: String)
  Xor(left: String, right: String)
}

pub fn parse(input: String) -> #(Dict(String, Bool), Dict(String, Op)) {
  let assert [initial, junctions] = string.split(input, "\n\n")

  let initial =
    initial
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [name, value] = string.split(line, ": ")
      case value {
        "0" -> #(name, False)
        "1" -> #(name, True)
        _ -> panic
      }
    })
    |> dict.from_list()

  let assert Ok(re) = regexp.from_string("(.+) (AND|OR|XOR) (.+) -> (.+)")
  let junctions =
    junctions
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [Match(submatches:, ..)] = regexp.scan(re, line)
      let assert [Some(left), Some(op), Some(right), Some(out)] = submatches
      case op {
        "AND" -> #(out, And(left, right))
        "OR" -> #(out, Or(left, right))
        "XOR" -> #(out, Xor(left, right))
        _ -> panic
      }
    })
    |> dict.from_list()

  #(initial, junctions)
}

fn incoming(wire, initial, junctions) {
  case dict.get(initial, wire) {
    Ok(bool) -> bool
    Error(_) -> get_wire_result(wire, initial, junctions)
  }
}

fn get_wire_result(
  wire: String,
  initial: Dict(String, Bool),
  junctions: Dict(String, Op),
) {
  let assert Ok(op) = dict.get(junctions, wire)

  case op {
    And(l, r) ->
      incoming(l, initial, junctions) && incoming(r, initial, junctions)

    Or(l, r) ->
      incoming(l, initial, junctions) || incoming(r, initial, junctions)

    Xor(l, r) ->
      incoming(l, initial, junctions) != incoming(r, initial, junctions)
  }
}

fn to_int(bits: List(Bool)) {
  case bits {
    [] -> 0
    [True, ..rest] -> 1 + 2 * to_int(rest)
    [False, ..rest] -> 2 * to_int(rest)
  }
}

pub fn pt_1(input: Input) {
  let #(initial, junctions) = input

  let z_wires =
    junctions
    |> dict.keys
    |> list.filter(string.starts_with(_, "z"))
    |> list.sort(string.compare)

  list.map(z_wires, get_wire_result(_, initial, junctions))
  |> to_int
}

pub fn pt_2(input: Input) {
  todo as "part 2 not implemented"
}
