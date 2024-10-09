import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/list
import gleam/int
import gleam/dict.{type Dict}
import gleam/option.{None, Some}

fn split(input: String) -> List(String) {
  input
  |> string.split(",")
}

fn hash_algorithm(str: String) -> Int {
  let codepoints =
    str
    |> string.to_utf_codepoints()
    |> list.map(string.utf_codepoint_to_int)
  use acc, c <- list.fold(codepoints, 0)
  let assert Ok(acc) = int.modulo({ acc + c } * 17, 256)
  acc
}

pub fn part1(input: String) -> String {
  input
  |> split
  |> list.fold(0, fn(acc, str) { acc + hash_algorithm(str) })
  |> string.inspect
}

type Instruction {
  Remove(label: String)
  Insert(label: String, focal: Int)
}

fn read_instruction(str: String) -> Instruction {
  case string.split(str, "=") {
    [label, focal_str] -> {
      let assert Ok(focal) = int.parse(focal_str)
      Insert(label, focal)
    }
    _ -> Remove(string.drop_right(str, 1))
  }
}

fn parse_instructions(insts: List(String)) -> Dict(Int, List(#(String, Int))) {
  use acc, inst <- list.fold(insts, dict.new())
  case read_instruction(inst) {
    Remove(label) -> remove_lens(acc, label)
    Insert(label, focal) -> insert_lens(acc, label, focal)
  }
}

fn remove_lens(boxes, label) {
  use v <- dict.update(boxes, hash_algorithm(label))
  case v {
    Some(lenses) ->
      case list.key_pop(lenses, label) {
        Ok(#(_, updated)) -> updated
        Error(Nil) -> lenses
      }
    None -> []
  }
}

fn insert_lens(boxes, label, focal) {
  use v <- dict.update(boxes, hash_algorithm(label))
  case v {
    Some(lenses) -> list.key_set(lenses, label, focal)
    None -> [#(label, focal)]
  }
}

fn focusing_power(boxes: Dict(Int, List(#(String, Int)))) -> Int {
  use acc, k, v <- dict.fold(boxes, 0)
  let box_acc = {
    use acc, lens, i <- list.index_fold(v, 0)
    acc + lens.1 * { i + 1 }
  }
  acc + { k + 1 } * box_acc
}

pub fn part2(input: String) -> String {
  input
  |> split
  |> parse_instructions
  |> focusing_power
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("15")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
