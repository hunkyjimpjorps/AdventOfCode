import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import my_utils/to
import shellout
import simplifile
import temporary

pub type Machine {
  Machine(lights: Set(Int), buttons: List(Set(Int)), joltage: Dict(Int, Int))
}

pub fn parse(input: String) {
  use line <- to.delimited_list(input, "\n")
  let assert [raw_lights, ..rest] = string.split(line, " ")
  let assert [raw_joltages, ..raw_buttons] = list.reverse(rest)
  Machine(
    parse_lights(raw_lights, 0, set.new()),
    list.map(raw_buttons, parse_buttons(_, set.new())),
    parse_joltages(raw_joltages),
  )
}

fn parse_lights(str: String, i: Int, acc: Set(Int)) -> Set(Int) {
  case str {
    "[" <> rest -> parse_lights(rest, i, acc)
    "#" <> rest -> parse_lights(rest, i + 1, set.insert(acc, i))
    "." <> rest -> parse_lights(rest, i + 1, acc)
    _ -> acc
  }
}

fn parse_buttons(str: String, acc: Set(Int)) -> Set(Int) {
  case string.pop_grapheme(str) {
    Ok(#(")", "")) -> acc
    Ok(#("(", rest)) | Ok(#(",", rest)) -> parse_buttons(rest, acc)
    Ok(#(n, rest)) -> parse_buttons(rest, set.insert(acc, to.int(n)))
    _ -> panic
  }
}

fn parse_joltages(str: String) {
  str
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.index_map(fn(n, i) { #(i, to.int(n)) })
  |> dict.from_list
}

pub fn pt_1(input: List(Machine)) {
  list.fold(input, 0, fn(acc, machine) { acc + solve_lights(machine, 1) })
}

fn solve_lights(machine: Machine, presses: Int) -> Int {
  case check_combinations(machine, presses) {
    True -> presses
    False -> solve_lights(machine, presses + 1)
  }
}

fn check_combinations(machine: Machine, presses: Int) -> Bool {
  machine.buttons
  |> list.combinations(presses)
  |> list.any(fn(buttons) {
    buttons
    |> list.fold(machine.lights, set.symmetric_difference)
    |> set.is_empty
  })
}

pub fn pt_2(input: List(Machine)) -> Int {
  list.map(input, solve_with_z3)
  |> int.sum
}

fn solve_with_z3(machine: Machine) -> Int {
  let sat =
    set_options
    <> declare_variables(machine)
    <> assert_linear_equations(machine)
    <> minimize_sum_of_variables(machine)
    <> check_satisfiability
  let assert Ok(Ok(res)) = send_file_to_z3(sat)
  echo res
  let assert [_, " " <> n, ..] = string.split(res, ")")
  to.int(n)
}

fn send_file_to_z3(
  sat: String,
) -> Result(Result(String, #(Int, String)), simplifile.FileError) {
  temporary.create(temporary.file(), fn(file_path) {
    let assert Ok(_) = simplifile.write(sat, to: file_path)
    shellout.command("z3", with: [file_path], in: ".", opt: [])
  })
}

// functions to put together a Z3 file to shellout with

const set_options: String = "(set-logic LIA)(set-option :produce-models true)"

const check_satisfiability: String = "(check-sat)(get-objectives)(exit)"

fn make_var(i: Int) -> String {
  " x" <> int.to_string(i)
}

fn minimize_sum_of_variables(machine: Machine) -> String {
  "(minimize (+"
  <> list.index_fold(machine.buttons, "", fn(acc, _, i) { acc <> make_var(i) })
  <> "))"
}

fn assert_linear_equations(machine: Machine) -> String {
  use acc, i, v <- dict.fold(machine.joltage, "")
  let vs =
    list.index_fold(machine.buttons, "", fn(acc, b, j) {
      case set.contains(b, i) {
        True -> acc <> make_var(j)
        False -> acc
      }
    })
  acc <> "(assert (= (+" <> vs <> ")" <> int.to_string(v) <> "))"
}

fn declare_variables(m: Machine) -> String {
  list.index_fold(m.buttons, "", fn(acc, _, i) {
    let v = make_var(i)
    acc <> "(declare-const" <> v <> " Int)(assert (>=" <> v <> " 0))"
  })
}
