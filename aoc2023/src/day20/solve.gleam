import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/iterator.{type Iterator, type Step, Next}
import gleam/list
import gleam/queue.{type Queue}
import gleam/set
import gleam/string

type Node {
  Broadcaster(children: List(String))
  Flipflop(children: List(String), state: Power)
  Conjunction(children: List(String), state: Dict(String, TonePitch))
  Ground
}

type Tone {
  Tone(from: String, to: String, pitch: TonePitch)
}

type Power {
  On
  Off
}

type TonePitch {
  Low
  High
}

type State {
  State(
    nodes: Dict(String, Node),
    low: Int,
    high: Int,
    cycle: Int,
    sentry_nodes: Dict(String, Int),
  )
}

fn flip_power(p: Power) -> Power {
  case p {
    On -> Off
    Off -> On
  }
}

fn flip_flop_pitch(p: Power) -> TonePitch {
  case p {
    Off -> High
    On -> Low
  }
}

fn combinator_pitch(state) {
  case list.unique(dict.values(state)) {
    [High] -> Low
    _ -> High
  }
}

fn get_children(node) {
  case node {
    Flipflop(children: cs, ..) -> cs
    Conjunction(children: cs, ..) -> cs
    Broadcaster(children: cs) -> cs
    Ground -> []
  }
}

fn parse_node(input: String) -> #(String, Node) {
  let assert [full_name, children_str] = string.split(input, on: " -> ")
  let children = string.split(children_str, on: ", ")

  case full_name {
    "%" <> name -> #(name, Flipflop(children: children, state: Off))
    "&" <> name -> #(name, Conjunction(children: children, state: dict.new()))
    "broadcaster" -> #("broadcaster", Broadcaster(children: children))
    name -> #(name, Ground)
  }
}

fn to_initial_state(nodes: List(#(String, Node))) -> Dict(String, Node) {
  let node_dict = dict.from_list(nodes)
  let node_names = dict.keys(node_dict)

  let node_dict =
    node_dict
    |> dict.values
    |> list.map(get_children)
    |> list.concat
    |> set.from_list
    |> set.drop(dict.keys(node_dict))
    |> set.to_list
    |> list.fold(node_dict, fn(acc, n) { dict.insert(acc, n, Ground) })

  use name, node <- dict.map_values(node_dict)
  case node {
    Conjunction(state: _, children: chs) ->
      node_names
      |> list.filter(fn(n) {
        let assert Ok(node) = dict.get(node_dict, n)
        list.contains(get_children(node), any: name)
      })
      |> list.map(fn(n) { #(n, Low) })
      |> dict.from_list()
      |> fn(dict) { Conjunction(state: dict, children: chs) }
    other -> other
  }
}

fn add_to_queue(from, children, pitch, queue) {
  use acc, c <- list.fold(children, queue)
  queue.push_back(acc, Tone(from: from, to: c, pitch: pitch))
}

fn add_tones(state: State, nodes, pitch, n) {
  case pitch {
    Low ->
      State(..state, nodes: nodes, low: state.low + n, cycle: state.cycle + 1)
    High ->
      State(..state, nodes: nodes, high: state.high + n, cycle: state.cycle + 1)
  }
}

fn press_button_once(initial: State, queue: Queue(Tone)) {
  let State(nodes: nodes, ..) = initial

  use <- bool.guard(queue.is_empty(queue), initial)
  let assert Ok(#(Tone(from_name, to_name, pitch), rest)) =
    queue.pop_front(queue)

  let assert Ok(to_node) = dict.get(nodes, to_name)
  case to_node {
    Broadcaster(children) -> {
      let new_state =
        add_tones(initial, nodes, pitch, list.length(children) + 1)

      let new_queue = add_to_queue(to_name, children, pitch, rest)
      press_button_once(new_state, new_queue)
    }

    Conjunction(state: state, children: children) -> {
      let new_state =
        state
        |> dict.insert(from_name, pitch)

      let updated_nodes =
        Conjunction(state: new_state, children: children)
        |> dict.insert(nodes, to_name, _)

      let pitch_out = combinator_pitch(new_state)

      let new_state =
        add_tones(initial, updated_nodes, pitch_out, list.length(children))
        |> check_for_interesting_node(from_name, pitch_out)

      add_to_queue(to_name, children, pitch_out, rest)
      |> press_button_once(new_state, _)
    }

    Flipflop(..) if pitch == High ->
      press_button_once(State(..initial, cycle: initial.cycle + 1), rest)

    Flipflop(state: state, children: children) -> {
      let updated_nodes =
        Flipflop(state: flip_power(state), children: children)
        |> dict.insert(nodes, to_name, _)

      let pitch_out = flip_flop_pitch(state)
      let new_state =
        add_tones(initial, updated_nodes, pitch_out, list.length(children))

      add_to_queue(to_name, children, flip_flop_pitch(state), rest)
      |> press_button_once(new_state, _)
    }

    Ground(..) ->
      press_button_once(State(..initial, cycle: initial.cycle + 1), rest)
  }
}

pub fn part1(input: String) {
  let initial_state =
    input
    |> string.split(on: "\n")
    |> list.map(parse_node)
    |> to_initial_state()

  iterator.iterate(
    from: State(initial_state, 0, 0, 1, dict.new()),
    with: press_button_once(_, queue.from_list([
      Tone("button", "broadcaster", Low),
    ])),
  )
  |> iterator.at(1000)
  |> fn(s) {
    let assert Ok(State(high: high, low: low, ..)) = s
    high * low
  }
  |> string.inspect
}

fn check_for_interesting_node(state, name, pitch_out) {
  case name, pitch_out {
    "rk", High | "cd", High | "zf", High | "qx", High ->
      State(
        ..state,
        sentry_nodes: dict.insert(state.sentry_nodes, name, state.cycle),
      )
    _, _ -> state
  }
}

pub fn part2(input: String) {
  let initial_state =
    input
    |> string.split(on: "\n")
    |> list.map(parse_node)
    |> to_initial_state()

  iterator.iterate(
    from: State(initial_state, 0, 0, 1, dict.new()),
    with: press_button_once(_, queue.from_list([
      Tone("button", "broadcaster", Low),
    ])),
  )
  |> iterator.drop_while(fn(s) { dict.size(s.sentry_nodes) < 4 })
  |> iterator.step
  |> fn(s: Step(State, Iterator(State))) {
    let assert Next(goal, _rest) = s
    goal.sentry_nodes
  }
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("20")
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
