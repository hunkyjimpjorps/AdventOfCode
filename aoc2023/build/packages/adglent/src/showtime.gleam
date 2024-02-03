import glint.{type CommandInput, flag}
import glint/flag
import glint/flag/constraint.{one_of}
import gleam/result
import gleam/string
import showtime/internal/common/cli.{Mixed, No, Yes}
@target(erlang)
import gleam/list
@target(erlang)
import gleam/option.{None, Some}
@target(erlang)
import gleam/erlang.{start_arguments}
@target(erlang)
import showtime/internal/common/test_suite.{EndTestRun, StartTestRun}
@target(erlang)
import showtime/internal/erlang/event_handler
@target(erlang)
import showtime/internal/erlang/module_handler
@target(erlang)
import showtime/internal/erlang/runner
@target(erlang)
import showtime/internal/erlang/discover.{
  collect_modules, collect_test_functions,
}

// @target(javascript)
// import gleam/io

@target(erlang)
pub fn main() {
  use module_list, ignore_tags, capture <- start_with_args(start_arguments())
  // Start event handler which will collect test-results and eventually
  // print test report
  let test_event_handler = event_handler.start()
  // Start module handler which receives msg about modules to test and
  // runs the test-suite for the module
  let test_module_handler =
    module_handler.start(
      test_event_handler,
      collect_test_functions,
      runner.run_test_suite,
      ignore_tags,
      capture,
    )

  test_event_handler(StartTestRun)
  // Collect modules and notify the module handler to start the test-suites
  let modules = collect_modules(test_module_handler, module_list)
  test_event_handler(EndTestRun(
    modules
    |> list.length(),
  ))
  Nil
}

fn start_with_args(args, func) {
  let modules_flag =
    flag.string_list()
    |> flag.default([])
    |> flag.description("Run only tests in the modules in this list")

  let ignore_flag =
    flag.string_list()
    |> flag.default([])
    |> flag.description(
      "Ignore tests that are have tags matching a tag in this list",
    )

  let capture_flag =
    flag.string()
    |> flag.default("no")
    |> flag.constraint(one_of(["yes", "no", "mixed"]))
    |> flag.description(
      "Capture output: no (default) - output when tests are run, yes - output is captured and shown in report, mixed - output when run and in report",
    )

  glint.new()
  |> glint.add(
    at: [],
    do: glint.command(mk_runner(func, _))
    |> glint.flag("modules", modules_flag)
    |> glint.flag("ignore", ignore_flag)
    |> glint.flag("capture", capture_flag)
    |> glint.description("Runs test"),
  )
  |> glint.with_pretty_help(glint.default_pretty_help())
  |> glint.run(args)
}

fn mk_runner(func, command: CommandInput) {
  let assert Ok(module_list) =
    command.flags
    |> flag.get_strings("modules")
    |> result.map(fn(modules) {
      case modules {
        [] -> None
        modules -> Some(modules)
      }
    })
  let assert Ok(ignore_tags) =
    command.flags
    |> flag.get_strings("ignore")

  let assert Ok(capture_output) =
    command.flags
    |> flag.get_string("capture")
    |> result.map(fn(arg) { string.lowercase(arg) })
    |> result.map(fn(arg) {
      case arg {
        "no" -> No
        "yes" -> Yes
        "mixed" -> Mixed
      }
    })
  func(module_list, ignore_tags, capture_output)
}
