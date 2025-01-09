import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import my_utils/to
import tote/bag.{type Bag}

pub type Event {
  NewGuard(Int)
  FallAsleep(Int)
  WakeUp(Int)
}

fn max_tuple_key(a: #(k, Int), b: #(k, Int)) {
  case a.1 > b.1 {
    True -> a
    False -> b
  }
}

fn get_minute(time_mark: String) {
  let assert Ok(#(_, min)) = string.split_once(time_mark, ":")
  to.int(min)
}

fn parse_event(line: String) {
  let assert Ok(#(time, event)) = string.split_once(line, "] ")

  case event {
    "Guard #" <> rest ->
      rest |> string.replace(" begins shift", "") |> to.int |> NewGuard
    "wakes up" -> time |> get_minute |> WakeUp
    "falls asleep" -> time |> get_minute |> FallAsleep
    _ -> panic
  }
}

fn compile_records(records: List(Event), current, acc) {
  case records {
    [] -> acc
    [NewGuard(g), ..rest] -> compile_records(rest, g, acc)
    [FallAsleep(from), WakeUp(to), ..rest] -> {
      let minutes =
        list.range(from, to - 1)
        |> bag.from_list
      dict.upsert(acc, current, fn(bag) {
        case bag {
          option.None -> minutes
          option.Some(v) -> bag.merge(v, minutes)
        }
      })
      |> compile_records(rest, current, _)
    }
    _ -> panic as "unexpected order of events"
  }
}

pub fn parse(input: String) -> Dict(Int, Bag(Int)) {
  input
  |> string.split("\n")
  |> list.sort(string.compare)
  |> list.map(parse_event)
  |> compile_records(0, dict.new())
}

pub fn pt_1(input: Dict(Int, Bag(Int))) {
  let assert Ok(#(sleepiest_guard, _)) =
    input
    |> dict.map_values(fn(_, bag) { bag.size(bag) })
    |> dict.to_list
    |> list.reduce(max_tuple_key)

  let assert Ok(#(sleepiest_minute, _)) =
    dict.get(input, sleepiest_guard)
    |> result.unwrap(bag.new())
    |> bag.to_list
    |> list.reduce(max_tuple_key)

  sleepiest_guard * sleepiest_minute
}

pub fn pt_2(input: Dict(Int, Bag(Int))) {
  let assert Ok(#(guard, #(minute, _))) =
    input
    |> dict.map_values(fn(_, bag) {
      let assert Ok(most_frequent) =
        bag |> bag.to_list |> list.reduce(max_tuple_key)
      most_frequent
    })
    |> dict.to_list
    |> list.reduce(fn(a, b) {
      case a.1.1 > b.1.1 {
        True -> a
        False -> b
      }
    })

  guard * minute
}
