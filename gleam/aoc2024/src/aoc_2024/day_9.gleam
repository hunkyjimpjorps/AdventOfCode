import gleam/bool
import gleam/list
import gleam/string
import my_utils/to

type State {
  Filled
  Empty
}

pub type Block {
  Block(n: Int)
  FreeSpace
}

pub type File {
  File(size: Int, id: Int)
  FreeSpan(size: Int)
}

pub fn parse(input: String) {
  do_parse(input, Filled, 0, [])
}

fn do_parse(input: String, state: State, file_index: Int, acc: List(Block)) {
  case state, string.pop_grapheme(input) {
    _, Error(_) -> list.reverse(acc)
    Filled, Ok(#(first, rest)) -> {
      let blocks = list.repeat(Block(file_index), to.int(first))
      do_parse(rest, Empty, file_index + 1, list.append(blocks, acc))
    }
    Empty, Ok(#(first, rest)) -> {
      let blocks = list.repeat(FreeSpace, to.int(first))
      do_parse(rest, Filled, file_index, list.append(blocks, acc))
    }
  }
}

fn replace(current: List(Block), movable: List(Block), acc: List(Block)) {
  case current, movable {
    remaining, [] -> list.append(list.reverse(acc), remaining)
    [FreeSpace, ..rest], [move, ..rest_to_move] ->
      replace(rest, rest_to_move, [move, ..acc])
    [b, ..rest], _ -> replace(rest, movable, [b, ..acc])
    _, _ -> panic
  }
}

pub fn pt_1(input: List(Block)) {
  let free_spaces = list.count(input, fn(b) { b == FreeSpace })
  let filled_spaces = list.length(input) - free_spaces
  let steps =
    filled_spaces
    |> list.take(input, _)
    |> list.count(fn(b) { b == FreeSpace })
  let to_keep = list.take(input, filled_spaces)
  let to_move =
    input
    |> list.reverse
    |> list.filter(fn(b) { b != FreeSpace })
    |> list.take(steps)

  replace(to_keep, to_move, [])
  |> list.index_fold(0, fn(acc, block, index) {
    case block {
      Block(n) -> acc + n * index
      FreeSpace -> acc
    }
  })
}

fn find_free_space(drive, files) {
  use <- bool.guard(list.is_empty(files), drive)
  let assert [File(size, id) as next, ..rest_files] = files
  let drive_parts =
    list.split_while(drive, fn(f) {
      case f {
        File(_, other_id) if id == other_id -> False
        FreeSpan(free_size) if free_size >= size -> False
        _ -> True
      }
    })

  case drive_parts {
    #(_, [File(_, _), ..]) | #(_no_split, []) ->
      find_free_space(drive, rest_files)
    #(first, [FreeSpan(free_size), ..rest]) if free_size == size -> {
      let after_move = collapse_free_space(rest, next, [])
      find_free_space(list.flatten([first, [next], after_move]), rest_files)
    }
    #(first, [FreeSpan(free_size), ..rest]) -> {
      let after_move = collapse_free_space(rest, next, [])
      find_free_space(
        list.flatten([first, [next, FreeSpan(free_size - size)], after_move]),
        rest_files,
      )
    }
  }
}

fn collapse_free_space(drive: List(File), moved: File, acc) {
  case drive {
    [FreeSpan(a), f, FreeSpan(b), ..rest] if moved == f ->
      list.flatten([list.reverse(acc), [FreeSpan(a + f.size + b)], rest])
    [FreeSpan(a), f, ..rest] if moved == f ->
      list.flatten([list.reverse(acc), [FreeSpan(a + f.size)], rest])
    [f, FreeSpan(b), ..rest] if moved == f ->
      list.flatten([list.reverse(acc), [FreeSpan(f.size + b)], rest])
    [f, ..rest] if moved == f ->
      list.flatten([list.reverse(acc), [FreeSpan(f.size)], rest])
    [other, ..rest] -> collapse_free_space(rest, moved, [other, ..acc])
    [] -> list.reverse(acc)
  }
}

pub fn pt_2(input: List(Block)) {
  let drive =
    input
    |> list.chunk(fn(n) { n })
    |> list.map(fn(blocks) {
      case blocks {
        [Block(n), ..] -> File(size: list.length(blocks), id: n)
        [FreeSpace, ..] -> FreeSpan(size: list.length(blocks))
        _ -> panic
      }
    })

  let files =
    drive
    |> list.reverse
    |> list.filter(fn(f) {
      case f {
        File(_, _) -> True
        _ -> False
      }
    })

  find_free_space(drive, files)
  |> list.flat_map(fn(f) {
    case f {
      File(size, id) -> list.repeat(id, size)
      FreeSpan(size) -> list.repeat(0, size)
    }
  })
  |> list.index_fold(0, fn(acc, block, index) { acc + block * index })
}
