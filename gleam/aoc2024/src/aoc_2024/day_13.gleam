import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string
import my_utils/to

pub type Move {
  Move(x: Int, y: Int)
}

pub type Machine {
  Machine(a: Move, b: Move, target: Move)
}

pub fn parse(input: String) -> List(Machine) {
  let assert Ok(button) = regexp.from_string("Button .: X\\+(\\d+), Y\\+(\\d+)")
  let assert Ok(prize) = regexp.from_string("Prize: X=(\\d+), Y=(\\d+)")

  let machines = string.split(input, "\n\n")
  use line <- list.map(machines)
  let assert [button_a, button_b, prize_loc] = string.split(line, "\n")
  let assert [Match(submatches: [Some(a_x), Some(a_y)], ..)] =
    regexp.scan(with: button, content: button_a)
  let assert [Match(submatches: [Some(b_x), Some(b_y)], ..)] =
    regexp.scan(with: button, content: button_b)
  let assert [Match(submatches: [Some(prize_x), Some(prize_y)], ..)] =
    regexp.scan(with: prize, content: prize_loc)
  Machine(
    Move(to.int(a_x), to.int(a_y)),
    Move(to.int(b_x), to.int(b_y)),
    Move(to.int(prize_x), to.int(prize_y)),
  )
}

fn reduce(target: Move, reduction: Move, times: Int) {
  Move(target.x - reduction.x * times, target.y - reduction.y * times)
}

fn det(m1, m2) {
  let Move(a, c) = m1
  let Move(b, d) = m2
  a * d - b * c
}

fn find(machine: Machine) {
  let a_presses = det(machine.target, machine.b) / det(machine.a, machine.b)
  let b_presses = det(machine.a, machine.target) / det(machine.a, machine.b)

  let check =
    machine.target
    |> reduce(machine.a, a_presses)
    |> reduce(machine.b, b_presses)
    == Move(0, 0)
  case check {
    True -> Ok(3 * a_presses + b_presses)
    False -> Error(Nil)
  }
}

pub fn pt_1(input: List(Machine)) {
  list.fold(input, 0, fn(acc, m) {
    case find(m) {
      Ok(tokens) -> acc + tokens
      _ -> acc
    }
  })
}

const adjustment = Move(-10_000_000_000_000, -10_000_000_000_000)

fn adjust(machine) {
  Machine(..machine, target: reduce(machine.target, adjustment, 1))
}

pub fn pt_2(input: List(Machine)) {
  list.filter_map(input, fn(m) { m |> adjust |> find })
  |> int.sum
}
