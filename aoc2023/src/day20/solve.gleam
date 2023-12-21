import adglent.{First, Second}
import gleam/io
import gleam/dict.{type Dict}
import gleam/queue.{type Queue}
import gleam/string
import gleam/list
import gleam/bool

type Node {
  Broadcaster(children: List(String))
  Flipflop(children: List(String), state: Power)
  Conjunction(children: List(String), state: Dict(String, TonePitch))
  Ground(children: List(String))
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

fn parse_node(input: String) -> #(String, Node) {
  let assert [full_name, children_str] = string.split(input, on: " -> ")
  let children = string.split(children_str, on: ", ")

  case full_name {
    "%" <> name -> #(name, Flipflop(children: children, state: Off))
    "&" <> name -> #(name, Conjunction(children: children, state: dict.new()))
    "broadcaster" -> #("broadcaster", Broadcaster(children: children))
    name -> #(name, Ground([]))
  }
}

fn to_initial_state(nodes: List(#(String, Node))) -> Dict(String, Node) {
  let node_dict = dict.from_list(nodes)
  let node_names = dict.keys(node_dict)

  use name, node <- dict.map_values(node_dict)
  case node {
    Conjunction(state: _, children: chs) ->
      node_names
      |> list.filter(fn(n) {
        let assert Ok(node) = dict.get(node_dict, n)
        list.contains(node.children, any: name)
      })
      |> list.map(fn(n) { #(n, Low) })
      |> dict.from_list()
      |> fn(dict) { Conjunction(state: dict, children: chs) }
    other -> other
  }
}

fn press_button_once(
  initial: #(Dict(String, Node), Int, Int),
  queue: Queue(Tone),
) {
  let #(nodes, high, low) = initial
  use <- bool.guard(queue.is_empty(queue), initial)
  let assert Ok(#(Tone(from_name, to_name, pitch) as tone, rest)) =
    queue.pop_front(queue)
  io.debug(tone)
  let assert Ok(to_node) = dict.get(nodes, to_name)
  case to_node {
    Broadcaster(children) ->
      list.fold(children, rest, fn(acc, c) {
        queue.push_back(acc, Tone(from: to_name, to: c, pitch: pitch))
      })
      |> press_button_once(initial, _)
      
    Conjunction(state: state, children: children) -> todo

    Flipflop(..) if pitch == High -> press_button_once(initial, rest)
    Flipflop(state: state, children: children) -> {
      let updated_nodes =
        dict.insert(
          nodes,
          to_name,
          Flipflop(state: flip_power(state), children: children),
        )
      let updated_queue =
        list.fold(children, rest, fn(acc, c) {
          queue.push_back(
            acc,
            Tone(from: to_name, to: c, pitch: flip_flop_pitch(state)),
          )
        })
      press_button_once(#(updated_nodes, 0, 0), updated_queue)
    }
    Ground(..) -> press_button_once(initial, rest)
  }
}

pub fn part1(input: String) {
  let initial_state =
    input
    |> string.split(on: "\n")
    |> list.map(parse_node)
    |> to_initial_state()

  press_button_once(
    #(initial_state, 0, 1),
    [Tone("button", "broadcaster", Low)]
    |> queue.from_list,
  )

  "1"
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
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
