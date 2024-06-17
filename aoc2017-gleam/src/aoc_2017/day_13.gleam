import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex.{Match}
import gleam/string

pub type Layer {
  Layer(depth: Int, cycle: Int)
}

pub type Status {
  Caught(severity: Int)
  Free
}

pub fn parse(input: String) {
  let assert Ok(re) = regex.from_string("([0-9]+): ([0-9]+)")

  use acc, row <- list.fold(string.split(input, "\n"), [])
  let assert [Match(submatches: [Some(depth), Some(cycle)], ..)] =
    regex.scan(row, with: re)
  let assert Ok(depth) = int.parse(depth)
  let assert Ok(cycle) = int.parse(cycle)
  [Layer(depth, cycle), ..acc]
}

fn severity(time: Int, depth: Int, cycle: Int) {
  case { time + depth } % { 2 * { cycle - 1 } } {
    0 -> Caught(cycle * depth)
    _ -> Free
  }
}

pub fn pt_1(input: List(Layer)) {
  use acc, layer <- list.fold(input, 0)
  case severity(0, layer.depth, layer.cycle) {
    Free -> acc
    Caught(severity) -> acc + severity
  }
}

pub fn pt_2(input: List(Layer)) {
  find_delay(0, input)
}

fn find_delay(delay: Int, layers: List(Layer)) {
  let trial_run =
    list.try_fold(layers, Free, fn(_, layer) {
      case severity(delay, layer.depth, layer.cycle) {
        Free -> Ok(Free)
        Caught(_) -> Error(Nil)
      }
    })
  case trial_run {
    Ok(_) -> delay
    _err -> find_delay(delay + 1, layers)
  }
}
