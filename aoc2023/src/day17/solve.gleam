import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/set.{type Set}
import utilities/array2d.{type Posn, Posn}
import utilities/prioqueue.{type PriorityQueue}

type State {
  State(posn: Posn, heatloss: Int, previous: Posn, history: List(Posn))
}

const deltas = [Posn(-1, 0), Posn(1, 0), Posn(0, -1), Posn(0, 1)]

fn make_key(s: State) {
  #(s.posn, same_dir(s))
}

fn same_dir(s: State) {
  case s.history {
    [] -> []
    [first, ..] as deltas ->
      list.take_while(deltas, fn(d) { d == first })
      |> list.take(10)
  }
}

fn is_goal(s: State, min_run: Int, goal: Posn) {
  goal == s.posn && list.length(same_dir(s)) >= min_run
}

fn find_good_neighbors(max: Int, min: Int, s: State, grid) {
  deltas
  |> list.filter(eliminate_bad_neighbors(_, s, max, min, grid))
  |> list.map(make_state(_, s, grid))
}

fn eliminate_bad_neighbors(d: Posn, s: State, max, min, grid) {
  let neighbor = array2d.add_posns(d, s.posn)

  use <- bool.guard(
    neighbor == s.previous || !dict.has_key(grid, neighbor),
    False,
  )
  case same_dir(s), list.length(same_dir(s)) {
    [prev, ..], l if l == max -> d != prev
    _, 0 -> True
    [prev, ..], l if l < min -> d == prev
    _, _ -> True
  }
}

fn make_state(d: Posn, s: State, grid) {
  let neighbor = array2d.add_posns(d, s.posn)
  let assert Ok(heat_lost) = dict.get(grid, neighbor)
  State(
    posn: neighbor,
    heatloss: s.heatloss + heat_lost,
    previous: s.posn,
    history: [d, ..s.history],
  )
}

fn find_path(
  grid: Dict(Posn, Int),
  queue: PriorityQueue(State),
  seen: Set(#(Posn, List(Posn))),
  get_neighbors: fn(State) -> List(State),
  is_goal: fn(State) -> Bool,
) {
  let assert Ok(#(state, rest)) = prioqueue.pop(queue)
  let key =
    make_key(
      state
      |> io.debug,
    )
  case set.contains(seen, key) {
    True -> find_path(grid, rest, seen, get_neighbors, is_goal)
    False -> {
      let now_seen = set.insert(seen, key)
      let neighbors = get_neighbors(state)
      case list.find(neighbors, is_goal) {
        Ok(final) -> final.heatloss
        _err -> {
          let now_queue =
            list.fold(neighbors, rest, fn(acc, n) {
              prioqueue.insert(acc, n, n.heatloss)
            })
          find_path(grid, now_queue, now_seen, get_neighbors, is_goal)
        }
      }
    }
  }
}

pub fn part1(input: String) {
  let raw_grid =
    input
    |> array2d.to_list_of_lists

  let grid = array2d.to_2d_intarray(raw_grid)

  let rmax = list.length(raw_grid)
  let assert Ok(cmax) =
    raw_grid
    |> list.first
    |> result.map(list.length)

  let start = State(Posn(0, 0), 0, Posn(0, 0), [])
  let goal = Posn(rmax, cmax)

  find_path(
    grid,
    prioqueue.insert(prioqueue.new(), start, 0),
    set.new(),
    find_good_neighbors(0, 3, _, grid),
    is_goal(_, 1, goal),
  )
  |> string.inspect
}

pub fn part2(input: String) {
  input
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("17")
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
