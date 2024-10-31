import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex.{Match}
import gleam/result
import gleam/string

type Reindeer {
  Reindeer(name: String, speed: Int, duration: Int, rest_period: Int)
}

type Doing {
  Flying
  Resting
}

fn parse_reindeer(line: String) {
  let assert Ok(re) =
    regex.from_string(
      "^(.*) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds.$",
    )

  let assert [
    Match(_, [Some(name), Some(speed), Some(duration), Some(rest_period)]),
  ] = regex.scan(line, with: re)

  Reindeer(
    name:,
    speed: assert_int(speed),
    duration: assert_int(duration),
    rest_period: assert_int(rest_period),
  )
}

fn simulate_reindeer(
  reindeer: Reindeer,
  distance: Int,
  state: Doing,
  time_left: Int,
) {
  case state {
    Flying if reindeer.duration > time_left ->
      distance + reindeer.speed * time_left
    Flying ->
      simulate_reindeer(
        reindeer,
        distance + reindeer.speed * reindeer.duration,
        Resting,
        time_left - reindeer.duration,
      )
    Resting if reindeer.rest_period > time_left -> distance
    Resting ->
      simulate_reindeer(
        reindeer,
        distance,
        Flying,
        time_left - reindeer.rest_period,
      )
  }
}

pub fn pt_1(input: String) {
  use acc, line <- list.fold(string.split(input, "\n"), 0)
  line |> parse_reindeer |> simulate_reindeer(0, Flying, 2503) |> int.max(acc)
}

type Lane {
  Lane(reindeer: Reindeer, distance: Int, points: Int, doing: Doing, for: Int)
}

fn simulate_step(lane: Lane) {
  case lane.doing {
    Flying if lane.for == 1 ->
      Lane(
        ..lane,
        distance: lane.distance + lane.reindeer.speed,
        doing: Resting,
        for: lane.reindeer.rest_period,
      )
    Flying ->
      Lane(
        ..lane,
        distance: lane.distance + lane.reindeer.speed,
        for: lane.for - 1,
      )
    Resting if lane.for == 1 ->
      Lane(..lane, doing: Flying, for: lane.reindeer.duration)
    Resting -> Lane(..lane, for: lane.for - 1)
  }
}

fn reward_leaders(lanes: List(Lane)) {
  let best = list.fold(lanes, 0, fn(acc, lane) { int.max(acc, lane.distance) })

  list.map(lanes, fn(lane) {
    use <- bool.guard(lane.distance != best, lane)
    Lane(..lane, points: lane.points + 1)
  })
}

fn run_race(lanes: List(Lane), time_left: Int) {
  case time_left {
    0 -> list.fold(lanes, 0, fn(acc, lane) { int.max(acc, lane.points) })
    n -> lanes |> list.map(simulate_step) |> reward_leaders |> run_race(n - 1)
  }
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let reindeer = parse_reindeer(line)
    Lane(reindeer, 0, 0, Flying, reindeer.duration)
  })
  |> run_race(2503)
}

fn assert_int(str: String) {
  str |> int.parse |> result.unwrap(0)
}
