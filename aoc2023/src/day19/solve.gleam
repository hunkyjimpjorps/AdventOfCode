import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/dict.{type Dict}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regex.{type Match, Match}
import gleam/list
import gleam/option.{Some}
import gleam/int

type Rating {
  XtremelyCool
  Musical
  Aerodynamic
  Shiny
}

type Part {
  Part(x: Int, m: Int, a: Int, s: Int)
}

type Action {
  Accept
  Reject
  SendTo(String)
}

type Rule {
  If(rating: Rating, comparison: Order, threshold: Int, do: Action)
  Just(do: Action)
}

type Workflow =
  Dict(String, List(Rule))

type Interval {
  Interval(min: Int, max: Int)
}

type PartRange {
  PartRange(x: Interval, m: Interval, a: Interval, s: Interval)
}

fn parse_workflow(input: String) -> Workflow {
  let assert Ok(re) = regex.from_string("(.*){(.*)}")

  use acc, line <- list.fold(string.split(input, "\n"), dict.new())
  let assert [Match(submatches: [Some(name), Some(all_rules)], ..)] =
    regex.scan(re, line)
  let rules =
    string.split(all_rules, ",")
    |> parse_rules
  dict.insert(acc, name, rules)
}

fn parse_rules(rules: List(String)) -> List(Rule) {
  let assert Ok(re_rule) = regex.from_string("(.*)(>|<)(.*):(.*)")
  use rule <- list.map(rules)
  case regex.scan(re_rule, rule) {
    [] -> Just(to_instruction(rule))
    [Match(submatches: [Some(r), Some(c), Some(t), Some(i)], ..)] ->
      If(to_rating(r), to_comp(c), to_val(t), to_instruction(i))
    _ -> panic
  }
}

fn to_instruction(rule: String) {
  case rule {
    "A" -> Accept
    "R" -> Reject
    name -> SendTo(name)
  }
}

fn to_rating(rating: String) {
  case rating {
    "x" -> XtremelyCool
    "m" -> Musical
    "a" -> Aerodynamic
    "s" -> Shiny
    _ -> panic
  }
}

fn get_rating(part: Part, rating: Rating) -> Int {
  case rating {
    XtremelyCool -> part.x
    Musical -> part.m
    Aerodynamic -> part.a
    Shiny -> part.s
  }
}

fn to_comp(comp: String) {
  case comp {
    "<" -> Lt
    ">" -> Gt
    _ -> panic
  }
}

fn to_val(val: String) {
  let assert Ok(n) = int.parse(val)
  n
}

fn parse_parts(input: String) -> List(Part) {
  let assert Ok(re) = regex.from_string("{x=(.*),m=(.*),a=(.*),s=(.*)}")

  use part <- list.map(string.split(input, "\n"))
  let assert [Match(submatches: [Some(x), Some(m), Some(a), Some(s)], ..)] =
    regex.scan(re, part)
  Part(to_val(x), to_val(m), to_val(a), to_val(s))
}

fn start_evaluating_workflow(part: Part, workflow: Workflow) -> Int {
  evaluate_workflow(part, "in", workflow)
}

fn evaluate_workflow(part: Part, name: String, workflow: Workflow) -> Int {
  let assert Ok(rules) = dict.get(workflow, name)
  case evaluate_rules(part, rules) {
    Accept -> part.x + part.m + part.a + part.s
    Reject -> 0
    SendTo(name) -> evaluate_workflow(part, name, workflow)
  }
}

fn evaluate_rules(part: Part, rules: List(Rule)) -> Action {
  case rules {
    [] -> panic
    [Just(do), ..] -> do
    [If(rating, comparison, threshold, do), ..rest] ->
      case int.compare(get_rating(part, rating), threshold) == comparison {
        True -> do
        False -> evaluate_rules(part, rest)
      }
  }
}

pub fn part1(input: String) {
  let assert Ok(#(workflows_str, parts_str)) = string.split_once(input, "\n\n")

  let workflows = parse_workflow(workflows_str)
  let parts = parse_parts(parts_str)

  list.map(parts, start_evaluating_workflow(_, workflows))
  |> int.sum
  |> string.inspect
}

fn size(interval: Interval) {
  interval.max - interval.min + 1
}

fn all_in_range(pr: PartRange) {
  size(pr.x) * size(pr.m) * size(pr.a) * size(pr.s)
}

fn get_partrange(pr: PartRange, rating: Rating) -> Interval {
  case rating {
    XtremelyCool -> pr.x
    Musical -> pr.m
    Aerodynamic -> pr.a
    Shiny -> pr.s
  }
}

fn update_partrange(pr: PartRange, rating: Rating, i: Interval) -> PartRange {
  case rating {
    XtremelyCool -> PartRange(..pr, x: i)
    Musical -> PartRange(..pr, m: i)
    Aerodynamic -> PartRange(..pr, a: i)
    Shiny -> PartRange(..pr, s: i)
  }
}

pub fn part2(input: String) {
  let assert Ok(#(workflows_str, _)) = string.split_once(input, "\n\n")

  let workflow = parse_workflow(workflows_str)
  let start = Interval(1, 4000)

  PartRange(start, start, start, start)
  |> evaluate_workflow_on_range("in", workflow)
  |> string.inspect
}

fn evaluate_workflow_on_range(
  pr: PartRange,
  name: String,
  workflow: Workflow,
) -> Int {
  let assert Ok(rules) = dict.get(workflow, name)
  evaluate_rules_on_range(pr, rules, workflow)
}

fn evaluate_rules_on_range(
  pr: PartRange,
  rules: List(Rule),
  workflow: Workflow,
) -> Int {
  case rules {
    [Just(Accept), ..] -> all_in_range(pr)
    [Just(Reject), ..] -> 0
    [Just(SendTo(name)), ..] -> evaluate_workflow_on_range(pr, name, workflow)
    [If(rating, comparison, t, action), ..rest] -> {
      let mod_i = get_partrange(pr, rating)
      case comparison {
        Eq -> panic
        Lt ->
          split_range(
            keep: update_partrange(pr, rating, Interval(mod_i.min, t - 1)),
            and_do: action,
            pass: update_partrange(pr, rating, Interval(t, mod_i.max)),
            and_eval: rest,
            with: workflow,
          )
        Gt ->
          split_range(
            keep: update_partrange(pr, rating, Interval(t + 1, mod_i.max)),
            and_do: action,
            pass: update_partrange(pr, rating, Interval(mod_i.min, t)),
            and_eval: rest,
            with: workflow,
          )
      }
    }
    [] -> panic
  }
}

fn split_range(
  keep keep: PartRange,
  and_do action: Action,
  pass pass: PartRange,
  and_eval rest: List(Rule),
  with workflow: Workflow,
) -> Int {
  int.add(
    evaluate_rules_on_range(keep, [Just(action)], workflow),
    evaluate_rules_on_range(pass, rest, workflow),
  )
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("19")
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
