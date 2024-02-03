import adglent
import gleam/string
import gleam/result
import priv/template
import priv/templates/testfile_gleeunit
import priv/templates/testfile_showtime
import priv/templates/solution
import priv/toml
import priv/aoc_client
import priv/errors
import simplifile

pub fn main() {
  let day =
    case adglent.start_arguments() {
      [day] -> Ok(day)
      args -> Error("Expected day - found: " <> string.join(args, ", "))
    }
    |> errors.map_error("Error when parsing command args")
    |> errors.print_error
    |> errors.assert_ok

  let aoc_toml =
    simplifile.read("aoc.toml")
    |> errors.map_error("Could not read aoc.toml")
    |> errors.print_error
    |> errors.assert_ok

  let aoc_toml_version = toml.get_int(aoc_toml, ["version"])
  let year =
    toml.get_string(aoc_toml, ["year"])
    |> errors.map_error("Could not read \"year\" from aoc.toml")
    |> errors.print_error
    |> errors.assert_ok
  let session =
    toml.get_string(aoc_toml, ["session"])
    |> errors.map_error("Could not read \"session\" from aoc.toml")
    |> errors.print_error
    |> errors.assert_ok

  let showtime = case aoc_toml_version {
    Ok(2) -> {
      toml.get_bool(aoc_toml, ["showtime"])
      |> errors.map_error("Could not read \"showtime\" from aoc.toml")
      |> errors.print_error
      |> errors.assert_ok
    }
    _ ->
      toml.get_string(aoc_toml, ["showtime"])
      |> result.map(fn(bool_string) {
        case bool_string {
          "True" -> True
          _ -> False
        }
      })
      |> errors.map_error("Could not read \"showtime\" from aoc.toml")
      |> errors.print_error
      |> errors.assert_ok
  }

  let test_folder = adglent.get_test_folder(day)
  let test_file = test_folder <> "/day" <> day <> "_test.gleam"

  simplifile.create_directory_all(test_folder)
  |> errors.map_error("Could not create folder \"" <> test_folder <> "\"")
  |> errors.print_error
  |> errors.assert_ok

  let testfile_template = case showtime {
    True -> testfile_showtime.template
    False -> testfile_gleeunit.template
  }

  template.render(testfile_template, [#("day", day)])
  |> create_file_if_not_present(test_file)
  |> errors.print_result
  |> errors.assert_ok

  let solutions_folder = "src/day" <> day
  let solution_file = solutions_folder <> "/solve.gleam"

  simplifile.create_directory_all(solutions_folder)
  |> errors.map_error("Could not create folder \"" <> solutions_folder <> "\"")
  |> errors.print_error
  |> errors.assert_ok

  template.render(solution.template, [#("day", day)])
  |> create_file_if_not_present(solution_file)
  |> errors.print_result
  |> errors.assert_ok

  create_file_if_not_present("input.txt", solutions_folder <> "/.gitignore")
  |> errors.print_result
  |> errors.assert_ok

  let input =
    aoc_client.get_input(year, day, session)
    |> errors.map_error("Error when fetching input")
    |> errors.print_error
    |> errors.assert_ok

  input
  |> string.trim
  |> create_file_if_not_present(solutions_folder <> "/input.txt")
  |> errors.print_result
  |> errors.assert_ok
}

fn create_file_if_not_present(
  content: String,
  path: String,
) -> Result(String, String) {
  case simplifile.is_file(path) {
    True -> {
      Ok(path <> " already exists - skipped")
    }
    False -> {
      use _ <- result.try(
        simplifile.create_file(path)
        |> errors.map_messages("Created " <> path, "Could not create " <> path),
      )
      simplifile.write(content, to: path)
      |> errors.map_messages("Wrote " <> path, "Could not write to " <> path)
    }
  }
}
