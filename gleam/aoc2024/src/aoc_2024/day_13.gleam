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

fn press(button: Move, times) {
  Move(button.x * times, button.y * times)
}

fn reduce(target: Move, reduction: Move) {
  Move(target.x - reduction.x, target.y - reduction.y)
}

fn find(machine: Machine) {
  let Machine(Move(ax, ay) as a, Move(bx, by) as b, Move(mx, my) as m) = machine

  let a_presses = { mx * by - my * bx } / { ax * by - ay * bx }
  let b_presses = { my * ax - mx * ay } / { ax * by - ay * bx }

  let check =
    m |> reduce(press(a, a_presses)) |> reduce(press(b, b_presses))
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
  Machine(..machine, target: reduce(machine.target, adjustment))
}

pub fn pt_2(input: List(Machine)) {
  list.filter_map(input, fn(m) { m |> adjust |> find })
  |> int.sum
}
