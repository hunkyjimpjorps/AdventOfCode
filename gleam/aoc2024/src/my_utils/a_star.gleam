import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result

/// Generates a path between the start and the goal coordinates that are in the format #(x: Int, y: Int) while avoiding the coordinates in the obstacles list.
/// The returned path excludes the starting point but includes the end point.
///
/// ## Examples
///
/// ```gleam
/// a_star(start: #(0, 0), goal: #(2, 2), obstacles: [#(1, 1)])
/// // Ok([#(0, 1), #(1, 2), #(2, 2)])
/// //
/// // S = Start, P = Path, X = Obstacle, E = End
/// // S - -
/// // P X -
/// // - P E
/// ```
pub fn a_star(
  start start: #(Int, Int),
  goal goal: #(Int, Int),
  obstacles obstacles: List(#(Int, Int)),
) {
  let open_set = [start]

  let g_score = dict.new() |> dict.insert(start, 0.0)

  let f_score = dict.new() |> dict.insert(start, heuristic(start, goal))

  do_a_star(open_set, f_score, g_score, goal, dict.new(), obstacles)
}

fn infinity() {
  4_294_967_296
}

fn reconstruct_path(
  came_from: dict.Dict(#(Int, Int), #(Int, Int)),
  current: #(Int, Int),
  total_path,
) {
  case
    dict.keys(came_from)
    |> list.contains(current)
  {
    True ->
      reconstruct_path(
        came_from,
        case dict.get(came_from, current) {
          Ok(value) -> value
          Error(_) -> panic as "unreachable"
        },
        list.prepend(total_path, current),
      )
    False -> total_path
  }
}

fn open_set_sorted_by_f_score(open_set, f_score: dict.Dict(#(Int, Int), Float)) {
  list.sort(open_set, fn(a, b) {
    let ascore = case dict.get(f_score, a) {
      Error(_) -> infinity() |> int.to_float

      Ok(score) -> score
    }
    let bscore = case dict.get(f_score, b) {
      Error(_) -> infinity() |> int.to_float
      Ok(score) -> score
    }

    case ascore <. bscore {
      True -> Lt
      False ->
        case ascore >. bscore {
          True -> Gt
          False -> Eq
        }
    }
  })
}

fn get_neighbors_of_current(current: #(Int, Int), goal: #(Int, Int)) {
  [
    #(current.0, current.1 - 1),
    #(current.0 - 1, current.1),
    #(current.0 + 1, current.1),
    #(current.0, current.1 + 1),
  ]
  |> list.filter(fn(tup) {
    tup.0 >= 0 && tup.1 >= 0 && tup.0 <= goal.0 && tup.1 <= goal.1
  })
}

fn heuristic(neighbor: #(Int, Int), goal: #(Int, Int)) -> Float {
  {
    int.absolute_value(neighbor.0 - goal.0)
    + int.absolute_value(neighbor.1 - goal.1)
  }
  |> int.to_float
}

fn distance(goal: #(Int, Int), current: #(Int, Int)) -> Float {
  {
    { int.power(goal.0 - current.0, 2.0) |> result.unwrap(0.0) }
    +. { int.power(goal.1 - current.1, 2.0) |> result.unwrap(0.0) }
  }
  |> float.square_root
  |> result.unwrap(0.0)
}

fn handle_neighbors_of_current(
  neighbors: List(#(Int, Int)),
  f_score: dict.Dict(#(Int, Int), Float),
  g_score: dict.Dict(#(Int, Int), Float),
  came_from,
  current,
  goal,
  open_set,
  obstacles: List(#(Int, Int)),
) {
  case neighbors {
    [neighbor, ..rest] -> {
      use <- bool.lazy_guard(list.contains(obstacles, neighbor), fn() {
        handle_neighbors_of_current(
          rest,
          g_score,
          f_score,
          came_from,
          current,
          goal,
          open_set,
          obstacles,
        )
      })

      let tentative_g_score =
        {
          case dict.get(g_score, current) {
            Ok(value) -> value
            Error(_) -> infinity() |> int.to_float
          }
        }
        +. distance(goal, current)

      case
        tentative_g_score
        <. case dict.get(g_score, neighbor) {
          Ok(value) -> value
          Error(_) -> infinity() |> int.to_float()
        }
      {
        True -> {
          let came_from = dict.insert(came_from, neighbor, current)
          let g_score = dict.insert(g_score, neighbor, tentative_g_score)
          let f_score =
            dict.insert(
              f_score,
              neighbor,
              tentative_g_score +. heuristic(neighbor, goal),
            )

          let open_set = case list.contains(open_set, neighbor) {
            False -> [neighbor, ..open_set]
            True -> open_set
          }

          handle_neighbors_of_current(
            rest,
            f_score,
            g_score,
            came_from,
            current,
            goal,
            open_set,
            obstacles,
          )
        }
        False ->
          handle_neighbors_of_current(
            rest,
            f_score,
            g_score,
            came_from,
            current,
            goal,
            open_set,
            obstacles,
          )
      }
    }
    [] -> do_a_star(open_set, f_score, g_score, goal, came_from, obstacles)
  }
}

fn do_a_star(
  open_set: List(#(Int, Int)),
  f_score: dict.Dict(#(Int, Int), Float),
  g_score: dict.Dict(#(Int, Int), Float),
  goal: #(Int, Int),
  came_from: dict.Dict(#(Int, Int), #(Int, Int)),
  obstacles: List(#(Int, Int)),
) {
  case list.is_empty(open_set) {
    False -> {
      use current <- result.try(case
        open_set_sorted_by_f_score(open_set, f_score)
      {
        [lowest, ..] -> Ok(lowest)
        _ -> {
          Error(Nil)
        }
      })

      use <- bool.guard(
        current == goal,
        Ok(reconstruct_path(came_from, current, [])),
      )

      let open_set = list.filter(open_set, fn(value) { value != current })

      handle_neighbors_of_current(
        get_neighbors_of_current(current, goal),
        f_score,
        g_score,
        came_from,
        current,
        goal,
        open_set,
        obstacles,
      )
    }
    True -> Error(Nil)
  }
}
