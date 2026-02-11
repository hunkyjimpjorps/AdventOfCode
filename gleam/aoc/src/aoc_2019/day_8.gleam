import gleam/int
import gleam/io
import gleam/list
import gleam/string

const width = 25

const height = 6

pub fn parse(input: String) -> Parsed {
  input
  |> string.to_graphemes
  |> list.filter_map(int.parse)
  |> list.sized_chunk(width * height)
}

type Parsed =
  List(List(Int))

fn count_digit(layer, digit) {
  list.count(layer, fn(x) { x == digit })
}

pub fn pt_1(input: Parsed) {
  let assert Ok(least_zeros) =
    list.max(input, fn(layer1, layer2) {
      int.compare(count_digit(layer2, 0), count_digit(layer1, 0))
    })

  count_digit(least_zeros, 1) * count_digit(least_zeros, 2)
}

fn render_layer(image, layer, acc) {
  case image, layer {
    [], [] -> list.reverse(acc)
    [px, ..image_rest], [2, ..layer_rest]
    | [_, ..image_rest], [px, ..layer_rest]
    -> render_layer(image_rest, layer_rest, [px, ..acc])
    _, _ -> panic
  }
}

pub fn pt_2(input: Parsed) {
  let assert Ok(message) =
    input
    |> list.reverse
    |> list.reduce(fn(image, layer) { render_layer(image, layer, []) })

  message
  |> list.sized_chunk(width)
  |> list.each(fn(row) {
    row
    |> list.map(fn(ch) {
      case ch {
        1 -> "██"
        0 -> "  "
        _ -> panic
      }
    })
    |> string.concat
    |> io.println
  })
}
