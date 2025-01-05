import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn generate_password(id) {
  find_hash_in_order(id, 0, 8, <<>>)
}

fn find_hash_in_order(input, index, remaining, acc) {
  use <- bool.lazy_guard(remaining == 0, fn() {
    bit_array.base16_encode(acc) |> string.lowercase
  })

  let hash =
    crypto.hash(
      crypto.Md5,
      bit_array.from_string(input <> int.to_string(index)),
    )

  case hash {
    <<0:size(5)-unit(4), found:size(1)-unit(4), _rest:bits>> ->
      find_hash_in_order(input, index + 1, remaining - 1, <<
        acc:bits,
        found:size(1)-unit(4),
      >>)
    _ -> find_hash_in_order(input, index + 1, remaining, acc)
  }
}

pub fn pt_1(input: String) {
  generate_password(input)
}

fn generate_better_password(id) {
  let starting_password =
    list.range(0, 7) |> list.map(fn(n) { #(n, Error(Nil)) }) |> dict.from_list
  do_hash_find(id, 0, 8, starting_password)
}

fn do_hash_find(input, index, remaining, acc) {
  use <- bool.lazy_guard(remaining == 0, fn() {
    acc
    |> dict.to_list()
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.map(fn(tup) { tup.1 })
    |> result.values()
    |> list.filter_map(int.to_base_string(_, 16))
    |> string.join("")
    |> string.lowercase()
  })

  let hash =
    crypto.hash(
      crypto.Md5,
      bit_array.from_string(input <> int.to_string(index)),
    )

  case hash {
    <<0:size(5)-unit(4), pos:size(1)-unit(4), char:size(1)-unit(4), _rest:bits>> -> {
      case dict.get(acc, pos) {
        Ok(Error(..)) ->
          dict.insert(acc, pos, Ok(char))
          |> do_hash_find(input, index + 1, remaining - 1, _)
        Ok(Ok(..)) | Error(..) -> do_hash_find(input, index + 1, remaining, acc)
      }
    }
    _ -> do_hash_find(input, index + 1, remaining, acc)
  }
}

pub fn pt_2(input: String) {
  generate_better_password(input)
}
