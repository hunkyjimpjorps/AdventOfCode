import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleamy/priority_queue.{type Queue} as pq
import my_utils/coord.{type Coord, Coord}
import my_utils/from

pub type Tile {
  Start
  End
  Path
}

pub type Direction {
  North
  East
  South
  West
}

fn left(dir: Direction) -> Direction {
  case dir {
    North -> West
    West -> South
    South -> East
    East -> North
  }
}

fn right(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn to_delta(dir: Direction) -> Coord {
  case dir {
    North -> Coord(-1, 0)
    East -> Coord(0, 1)
    South -> Coord(1, 0)
    West -> Coord(0, -1)
  }
}

pub type Reindeer {
  Reindeer(posn: Coord, dir: Direction, score: Int)
}

pub fn parse(input: String) -> Dict(Coord, Tile) {
  from.try_grid(input, fn(c) {
    case c {
      "." -> Ok(Path)
      "S" -> Ok(Start)
      "E" -> Ok(End)
      _ -> Error(Nil)
    }
  })
}

fn find(input, tile) {
  input |> dict.filter(fn(_, v) { v == tile }) |> dict.keys
}

fn traverse_maze(
  queueing reindeers: Queue(Reindeer),
  running maze: Dict(Coord, Tile),
  seen seen: Set(#(Coord, Direction)),
  costs costs: Dict(Coord, Int),
  starting_best best: Int,
  destinations dests: List(#(Coord, Direction)),
) {
  case pq.pop(reindeers) {
    Error(_) -> #(best, costs)
    Ok(#(Reindeer(r_posn, r_dir, r_score) as reindeer, rest)) -> {
      let state = #(r_posn, r_dir)
      let new_costs =
        dict.upsert(costs, r_posn, fn(v) {
          case v {
            option.Some(score) -> int.min(score, r_score)
            option.None -> r_score
          }
        })
      case set.contains(seen, state), list.contains(dests, state) {
        True, False -> traverse_maze(rest, maze, seen, new_costs, best, dests)
        _, True -> {
          let new_best = int.min(r_score, best)
          traverse_maze(rest, maze, seen, new_costs, new_best, dests)
        }
        False, _ -> {
          let new_seen = set.insert(seen, state)
          let forward = coord.go(r_posn, to_delta(r_dir))
          let ahead = case dict.get(maze, forward) {
            Ok(_) -> [Reindeer(..reindeer, posn: forward, score: r_score + 1)]
            Error(_) -> []
          }
          let new_reindeers =
            [
              Reindeer(..reindeer, dir: left(r_dir), score: r_score + 1000),
              Reindeer(..reindeer, dir: right(r_dir), score: r_score + 1000),
              ..ahead
            ]
            |> list.fold(rest, pq.push)
          traverse_maze(new_reindeers, maze, new_seen, new_costs, best, dests)
        }
      }
    }
  }
}

fn compare_reindeer(r1: Reindeer, r2: Reindeer) {
  int.compare(r1.score, r2.score)
}

pub fn pt_1(input: Dict(Coord, Tile)) {
  let assert [start] = find(input, Start)
  let assert [end] = find(input, End)

  traverse_maze(
    queueing: pq.new(compare_reindeer)
      |> pq.push(Reindeer(posn: start, dir: East, score: 0)),
    running: input,
    seen: set.new(),
    costs: dict.new(),
    starting_best: 1_000_000_000,
    destinations: [#(end, North)],
  ).0
}

pub fn pt_2(input: Dict(Coord, Tile)) {
  let assert [start] = find(input, Start)
  let assert [end] = find(input, End)

  let going =
    traverse_maze(
      queueing: pq.new(compare_reindeer)
        |> pq.push(Reindeer(posn: start, dir: East, score: 0)),
      running: input,
      seen: set.new(),
      costs: dict.new(),
      starting_best: 1_000_000_000,
      destinations: [#(end, North)],
    )

  let coming =
    traverse_maze(
      queueing: pq.new(compare_reindeer)
        |> pq.push(Reindeer(posn: end, dir: South, score: 0)),
      running: input,
      seen: set.new(),
      costs: dict.new(),
      starting_best: 1_000_000_000,
      destinations: [#(start, West), #(start, South)],
    )

  coming.1
  |> dict.keys
  |> list.count(fn(k) {
    let assert Ok(to) = dict.get(going.1, k)
    let from = result.unwrap(dict.get(coming.1, k), 0)
    // I don't know why this works!
    to + from == going.0 || to + from + 1000 == going.0
  })
}
