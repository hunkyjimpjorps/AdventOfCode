import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

fn hash_algorithm(str: String) -> Int {
  let codepoints =
    str
    |> string.to_utf_codepoints()
    |> list.map(string.utf_codepoint_to_int)
  use acc, c <- list.fold(codepoints, 0)
  let assert Ok(acc) = int.modulo({ acc + c } * 17, 256)
  acc
}

pub fn pt_1(input: String) {
  input
  |> string.split(",")
  |> list.fold(0, fn(acc, str) { acc + hash_algorithm(str) })
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
    _ -> Remove(string.drop_end(str, 1))
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
  use v <- dict.upsert(boxes, hash_algorithm(label))
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
  use v <- dict.upsert(boxes, hash_algorithm(label))
  case v {
    Some(lenses) -> list.key_set(lenses, label, focal)
    None -> [#(label, focal)]
  }
}

fn focusing_power(boxes: Dict(Int, List(#(String, Int)))) -> Int {
  use acc, k, v <- dict.fold(boxes, 0)
  use acc, lens, i <- list.index_fold(v, acc)
  acc + { k + 1 } * lens.1 * { i + 1 }
}

pub fn pt_2(input: String) {
  input
  |> string.split(",")
  |> parse_instructions
  |> focusing_power
}
