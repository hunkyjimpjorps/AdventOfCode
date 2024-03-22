import gleam/io
import gleam/string
import gleam/set.{type Set}
import gleam/int
import gleam/regex.{Match}
import gleam/option.{Some}
import simplifile

pub opaque type Item {
  File(name: String, size: Int)
  Directory(name: String)
}

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day7/data.txt")
  let lines = string.split(data, "\n")

  mark_for_deletion(lines, 0, "", set.new())
  |> io.debug()
}

fn mark_for_deletion(
  lines: List(String),
  deleted: Int,
  current_folder: String,
  deleted_folders: Set(String),
) {
  case lines {
    [] -> deleted
    ["Folder: " <> folder, ..rest] ->
      mark_for_deletion(rest, deleted, folder, deleted_folders)
    [file, ..rest] -> {
      case
        string.contains(file, "temporary")
        || string.contains(file, "delete")
        || set.contains(deleted_folders, current_folder)
      {
        True ->
          case string.contains(file, "[FOLDER") {
            True -> {
              file
              |> get_folder_number()
              |> set.insert(deleted_folders, _)
              |> mark_for_deletion(rest, deleted, current_folder, _)
            }
            False -> {
              file
              |> get_file_size()
              |> int.add(deleted, _)
              |> mark_for_deletion(rest, _, current_folder, deleted_folders)
            }
          }
        False ->
          mark_for_deletion(rest, deleted, current_folder, deleted_folders)
      }
    }
  }
}

fn get_folder_number(file) {
  let assert Ok(re) = regex.from_string("\\[FOLDER ([0-9]+)\\]")

  let assert [Match(submatches: [Some(n)], ..)] = regex.scan(re, file)
  n
}

fn get_file_size(file) {
  let assert Ok(re) = regex.from_string("- .+ ([0-9]+)$")

  let assert [Match(submatches: [Some(n)], ..)] = regex.scan(re, file)
  let assert Ok(n) = int.parse(n)
  n
}
