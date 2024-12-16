import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
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
  reindeers: Queue(Reindeer),
  maze: Dict(Coord, Tile),
  seen: Set(#(Coord, Direction)),
  best: Int,
  dest: Coord,
  seats: Set(Coord),
) {
  case pq.pop(reindeers) {
    Error(_) -> #(best, set.size(seats))
    Ok(#(Reindeer(r_posn, r_dir, r_score) as reindeer, rest)) -> {
      let state = #(reindeer.posn, reindeer.dir)
      case set.contains(seen, state) {
        True -> traverse_maze(rest, maze, seen, best, dest, seats)
        False -> {
          let new_best = case r_posn == dest {
            True -> int.min(r_score, best)
            False -> best
          }
          let new_seats = case r_posn == dest, int.compare(r_score, best) {
            True, order.Lt -> set.map(seen, fn(s) { s.0 })
            True, order.Eq -> set.map(seen, fn(s) { s.0 }) |> set.union(seats)
            _, _ -> seats
          }
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
            |> list.fold(reindeers, pq.push)
          traverse_maze(
            new_reindeers,
            maze,
            new_seen,
            new_best,
            dest,
            new_seats,
          )
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
    pq.new(compare_reindeer)
      |> pq.push(Reindeer(posn: start, dir: East, score: 0)),
    input,
    set.new(),
    1_000_000_000,
    end,
    set.new(),
  )
}

pub fn pt_2(input: Dict(Coord, Tile)) {
  let assert [start] = find(input, Start)
  let assert [end] = find(input, End)

  traverse_maze(
    pq.new(compare_reindeer)
      |> pq.push(Reindeer(posn: start, dir: East, score: 0)),
    input,
    set.new(),
    1_000_000_000,
    end,
    set.new(),
  )
}
