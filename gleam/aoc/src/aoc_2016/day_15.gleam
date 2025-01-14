import gleam/list
import gleam/option
import gleam/regexp.{Match}
import my_utils/to

pub type Disc {
  Disc(index: Int, period: Int, initial: Int)
}

fn parse_line(line: String) {
  let assert Ok(re) =
    regexp.from_string(
      "Disc #(.) has (\\d+) positions; at time=0, it is at position (\\d)\\.",
    )

  let assert [Match(submatches:, ..)] = regexp.scan(with: re, content: line)
  let assert [index, period, initial] =
    submatches |> option.values() |> list.map(to.int)

  Disc(index, period, initial)
}

fn valid_disc(time, disc: Disc) {
  { time + disc.index + disc.initial } % disc.period == 0
}

fn next_second(discs: List(Disc), time) {
  case list.all(discs, valid_disc(time, _)) {
    True -> time
    False -> next_second(discs, time + 1)
  }
}

pub fn pt_1(input: String) {
  input
  |> to.delimited_list("\n", parse_line)
  |> next_second(0)
}

pub fn pt_2(input: String) {
  let discs = to.delimited_list(input, "\n", parse_line)
  [Disc(list.length(discs) + 1, 11, 0), ..discs] |> next_second(0)
}
