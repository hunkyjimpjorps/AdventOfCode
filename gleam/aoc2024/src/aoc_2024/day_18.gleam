import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue} as pq
import my_utils/a_star
import my_utils/to

pub type Tile {
  Clear
  Corrupted
}

pub fn parse(input: String) -> List(#(Int, Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(pair) {
    let assert [x, y] = string.split(pair, ",")
    #(to.int(x), to.int(y))
  })
}

const size = 70

const take = 1024

pub fn pt_1(input: List(#(Int, Int))) {
  input
  |> list.take(take)
  |> a_star.a_star(start: #(0, 0), goal: #(size, size), obstacles: _)
  |> result.map(list.length)
  |> result.unwrap(0)
}

fn neighbors_of(pt: #(Int, Int)) {
  let #(x, y) = pt
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
}

fn traverse_maze(
  queueing queue: Queue(#(Int, Int)),
  running maze: Dict(#(Int, Int), Tile),
  seen seen: Set(#(Int, Int)),
  destination dest: #(Int, Int),
) {
  case pq.pop(queue) {
    Error(_) -> Error(Nil)
    Ok(#(next, rest)) -> {
      case set.contains(seen, next), dest == next {
        True, False -> traverse_maze(rest, maze, seen, dest)
        _, True -> Ok(Nil)

        False, _ -> {
          next
          |> neighbors_of
          |> list.filter(fn(n) { dict.get(maze, n) == Ok(Clear) })
          |> list.fold(rest, pq.push)
          |> traverse_maze(maze, set.insert(seen, next), dest)
        }
      }
    }
  }
}

fn compare_points(r1: #(Int, Int), r2: #(Int, Int)) {
  int.compare(r1.0 + r1.1, r2.0 + r2.1)
}

pub fn pt_2(input: List(#(Int, Int))) {
  let starting_map =
    {
      use x <- list.flat_map(list.range(0, size))
      use y <- list.map(list.range(0, size))
      #(#(x, y), Clear)
    }
    |> dict.from_list
    |> list.fold(
      list.take(input, 1024),
      _,
      fn(acc, pt) { dict.insert(acc, pt, Corrupted) },
    )

  input
  |> list.drop(1024)
  |> list.try_fold(starting_map, fn(acc, next) {
    let acc = dict.insert(acc, next, Corrupted)
    let result =
      pq.new(compare_points)
      |> pq.push(#(0, 0))
      |> traverse_maze(acc, set.new(), #(size, size))

    case result {
      Ok(_) -> Ok(acc)
      Error(_) -> Error(next)
    }
  })
  |> result.unwrap_error(#(0, 0))
}
