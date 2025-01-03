import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string

type Input =
  #(Dict(String, Bool), Dict(String, Gate))

pub type Gate {
  And(left: String, right: String, out: String)
  Or(left: String, right: String, out: String)
  Xor(left: String, right: String, out: String)
}

pub fn parse(input: String) -> #(Dict(String, Bool), Dict(String, Gate)) {
  let assert [initial, gates] = string.split(input, "\n\n")

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
  let gates =
    gates
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [Match(submatches:, ..)] = regexp.scan(re, line)
      let assert [Some(left), Some(op), Some(right), Some(out)] = submatches
      case op {
        "AND" -> #(out, And(left, right, out))
        "OR" -> #(out, Or(left, right, out))
        "XOR" -> #(out, Xor(left, right, out))
        _ -> panic
      }
    })
    |> dict.from_list()

  #(initial, gates)
}

fn get_wire_result(
  wire: String,
  initial: Dict(String, Bool),
  gates: Dict(String, Gate),
) {
  let assert Ok(op) = dict.get(gates, wire)

  let f = case op {
    And(..) -> bool.and
    Or(..) -> bool.or
    Xor(..) -> bool.exclusive_nor
  }

  let get = fn(wire) {
    case dict.get(initial, wire) {
      Ok(bool) -> bool
      Error(_) -> get_wire_result(wire, initial, gates)
    }
  }

  f(get(op.left), get(op.right))
}

fn to_int(bits: List(Bool)) {
  case bits {
    [] -> 0
    [True, ..rest] -> 1 + 2 * to_int(rest)
    [False, ..rest] -> 2 * to_int(rest)
  }
}

pub fn pt_1(input: Input) {
  let #(initial, gates) = input

  let z_wires =
    gates
    |> dict.keys
    |> list.filter(string.starts_with(_, "z"))
    |> list.sort(string.compare)

  list.map(z_wires, get_wire_result(_, initial, gates))
  |> to_int
}

// implementation of piman51277/AdventOfCode's JS solution
// https://github.com/piman51277/AdventOfCode/blob/master/solutions/2024/24/index2prog.js
//

fn is_direct(gate: Gate) {
  string.starts_with(gate.left, "x") || string.starts_with(gate.right, "x")
}

fn is_output(gate: Gate) {
  string.starts_with(gate.out, "z")
}

fn is_first(gate: Gate) {
  case gate.left, gate.right {
    "x00", _ | _, "x00" -> True
    _, _ -> False
  }
}

fn is_z00(gate: Gate) {
  gate.out == "z00"
}

fn is_last(gate: Gate) {
  gate.out == "z45"
}

fn is_xor(gate: Gate) {
  case gate {
    Xor(..) -> True
    _ -> False
  }
}

fn is_or(gate: Gate) {
  case gate {
    Or(..) -> True
    _ -> False
  }
}

// Description of the types of gates found in this kind of adder:
//  * A    XOR B    -> VAL0     <- gate_type_0
//  * A    AND B    -> VAL1     <- gate_type_1
//  * VAL0 AND CIN  -> VAL2     <- gate_type_2
//  * VAL0 XOR CIN  -> SUM      <- gate_type_3
//  * VAL1 OR  VAL2 -> COUT     <- gate_type_4
//
// In the input, there's four categories of mistakes to look for:
// -- a type 0 gate is sending bits to the output
// -- a type 3 gate isn't sending bits to the output
// -- a gate wired to the output is not a type 3 or 4 gate
// -- a type 0 gate is not wired to a type 3 gate

fn find_bad_type_0(gates) {
  use j <- list.filter_map(gates)
  case
    { is_direct(j) && is_xor(j) && is_output(j) }
    && { bool.exclusive_or(is_first(j), is_z00(j)) }
  {
    True -> Ok(j.out)
    False -> Error(Nil)
  }
}

fn find_bad_type_3(gates) {
  use j <- list.filter_map(gates)
  case is_xor(j) && !is_direct(j) && !is_output(j) {
    True -> Ok(j.out)
    False -> Error(Nil)
  }
}

fn find_improper_outputs(gates) {
  use j <- list.filter_map(gates)
  case
    is_output(j)
    && { { is_last(j) && !is_or(j) } || { !is_last(j) && !is_xor(j) } }
  {
    True -> Ok(j.out)
    False -> Error(Nil)
  }
}

fn find_mismatched_gates(gates: List(Gate)) {
  let type_0 =
    list.filter(gates, fn(j) { is_xor(j) && is_direct(j) && !is_z00(j) })
  let type_3 = list.filter(gates, fn(j) { is_xor(j) && !is_direct(j) })

  // all type 0 gates have to connect to a type 3 gate 
  // find the type 0 gate that doesn't
  let assert Ok(bad_gate) =
    list.find(type_0, fn(j0) {
      !list.any(type_3, fn(j3) { { j3.left == j0.out || j3.right == j0.out } })
    })

  // find the OR gate that the bad gate ought to be connected to
  // the bad gate should take xAA and yAA as inputs, so the output should go to
  // a gate that outputs zAA
  let assert Ok(match) =
    list.find(gates, fn(j) {
      j.out == "z" <> { bad_gate.left |> string.drop_start(1) }
    })
  let assert Ok(or_match) =
    gates
    |> list.filter(is_or)
    |> list.find(fn(j) { j.out == match.left || j.out == match.right })

  case match {
    Xor(left:, right:, ..) if left == or_match.out -> [bad_gate.out, right]
    Xor(left:, ..) -> [bad_gate.out, left]
    _ -> panic
  }
}

pub fn pt_2(input: Input) {
  let #(_, gates) = input
  let gates = dict.values(gates)

  find_bad_type_0(gates)
  |> list.append(find_bad_type_3(gates))
  |> list.append(find_improper_outputs(gates))
  |> list.append(find_mismatched_gates(gates))
  |> list.sort(string.compare)
  |> string.join(",")
}
