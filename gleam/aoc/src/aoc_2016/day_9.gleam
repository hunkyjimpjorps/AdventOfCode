import gleam/string
import my_utils/to

fn decompress(input: String, with, acc: Int) {
  case string.pop_grapheme(input) {
    Error(..) -> acc
    Ok(#("\n", rest)) -> decompress(rest, with, acc)
    Ok(#("(", rest)) -> {
      let #(added, rest) = with(rest, "")
      decompress(rest, with, acc + added)
    }

    Ok(#(_, rest)) -> decompress(rest, with, acc + 1)
  }
}

fn read_marker(input: String, acc) {
  case string.pop_grapheme(input) {
    Ok(#(")", rest)) -> {
      let assert Ok(#(take, times)) = string.split_once(acc, "x")
      let take = to.int(take)
      let times = to.int(times)
      #(take * times, string.drop_start(rest, take))
    }
    Ok(#(next, rest)) -> read_marker(rest, acc <> next)
    Error(_) -> panic
  }
}

fn read_marker_v2(input: String, acc) {
  case string.pop_grapheme(input) {
    Ok(#(")", rest)) -> {
      let assert Ok(#(take, times)) = string.split_once(acc, "x")
      let take = to.int(take)
      let times = to.int(times)
      let contents = string.slice(rest, 0, take)
      #(
        decompress(contents, read_marker_v2, 0) * times,
        string.drop_start(rest, take),
      )
    }
    Ok(#(next, rest)) -> read_marker_v2(rest, acc <> next)
    Error(_) -> panic
  }
}

pub fn pt_1(input: String) {
  decompress(input, read_marker, 0)
}

pub fn pt_2(input: String) {
  decompress(input, read_marker_v2, 0)
}
