import gleam/list
import gleam/set
import gleam/string

fn parse_rule(raw: String) -> #(String, String) {
  let assert Ok(rule) = string.split_once(raw, " => ")
  rule
}

fn split_to_elements(raw: String) -> List(String) {
  case string.pop_grapheme(raw) {
    Error(_) -> []
    Ok(#(first, rest)) ->
      case string.pop_grapheme(rest) {
        Error(_) -> [first]
        Ok(#(next, after)) ->
          case next == string.lowercase(next) {
            True -> [first <> next, ..split_to_elements(after)]
            False -> [first, ..split_to_elements(rest)]
          }
      }
  }
}

fn parse(input: String) -> #(List(#(String, String)), String) {
  let assert [rules, base] = string.split(input, "\n\n")

  let rules = rules |> string.split("\n") |> list.map(parse_rule)
  #(rules, base)
}

fn generate_molecules(rules: List(#(String, String)), prefix, current) {
  let assert [first, ..rest] = current
  rules
  |> list.filter(fn(rule) { rule.0 == first })
  |> list.map(fn(rule) {
    list.concat([prefix, split_to_elements(rule.1), rest])
  })
}

fn check_all_atoms(rules, prefix, current, acc) {
  case current {
    [] -> set.size(acc)
    [first, ..rest] -> {
      let new_prefix = list.append(prefix, [first])
      generate_molecules(rules, prefix, current)
      |> list.fold(acc, set.insert)
      |> check_all_atoms(rules, new_prefix, rest, _)
    }
  }
}

pub fn pt_1(input: String) {
  let #(rules, base) = parse(input)
  check_all_atoms(rules, [], split_to_elements(base), set.new())
}

fn do_next_replacement(
  molecule: String,
  rules: List(#(String, String)),
  count: Int,
) -> Int {
  case molecule {
    "e" -> count
    mol -> {
      let assert Ok(#(to, from)) =
        rules |> list.find(fn(rule) { string.contains(mol, rule.1) })
      let assert Ok(#(left, right)) = mol |> string.split_once(from)
      do_next_replacement(left <> to <> right, rules, count + 1)
    }
  }
}

fn count_terminals(elements, total, outer, inner) {
  case elements {
    [] -> total - outer - 2 * inner - 1
    ["Rn", ..rest] | ["Ar", ..rest] ->
      count_terminals(rest, total + 1, outer + 1, inner)
    ["Y", ..rest] -> count_terminals(rest, total + 1, outer, inner + 1)
    [_, ..rest] -> count_terminals(rest, total + 1, outer, inner)
  }
}

pub fn pt_2(input: String) {
  let #(_, start) = parse(input)
  count_terminals(split_to_elements(start), 0, 0, 0)
}
