-module(adglent@day).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([main/0]).

-spec create_file_if_not_present(binary(), binary()) -> {ok, binary()} |
    {error, binary()}.
create_file_if_not_present(Content, Path) ->
    case simplifile:is_file(Path) of
        true ->
            {ok, <<Path/binary, " already exists - skipped"/utf8>>};

        false ->
            gleam@result:'try'(
                begin
                    _pipe = simplifile:create_file(Path),
                    priv@errors:map_messages(
                        _pipe,
                        <<"Created "/utf8, Path/binary>>,
                        <<"Could not create "/utf8, Path/binary>>
                    )
                end,
                fun(_) -> _pipe@1 = simplifile:write(Path, Content),
                    priv@errors:map_messages(
                        _pipe@1,
                        <<"Wrote "/utf8, Path/binary>>,
                        <<"Could not write to "/utf8, Path/binary>>
                    ) end
            )
    end.

-spec main() -> binary().
main() ->
    Day@1 = begin
        _pipe = case adglent:start_arguments() of
            [Day] ->
                {ok, Day};

            Args ->
                {error,
                    <<"Expected day - found: "/utf8,
                        (gleam@string:join(Args, <<", "/utf8>>))/binary>>}
        end,
        _pipe@1 = priv@errors:map_error(
            _pipe,
            <<"Error when parsing command args"/utf8>>
        ),
        _pipe@2 = priv@errors:print_error(_pipe@1),
        priv@errors:assert_ok(_pipe@2)
    end,
    Aoc_toml = begin
        _pipe@3 = simplifile:read(<<"aoc.toml"/utf8>>),
        _pipe@4 = priv@errors:map_error(
            _pipe@3,
            <<"Could not read aoc.toml"/utf8>>
        ),
        _pipe@5 = priv@errors:print_error(_pipe@4),
        priv@errors:assert_ok(_pipe@5)
    end,
    Aoc_toml_version = priv@toml:get_int(Aoc_toml, [<<"version"/utf8>>]),
    Year = begin
        _pipe@6 = priv@toml:get_string(Aoc_toml, [<<"year"/utf8>>]),
        _pipe@7 = priv@errors:map_error(
            _pipe@6,
            <<"Could not read \"year\" from aoc.toml"/utf8>>
        ),
        _pipe@8 = priv@errors:print_error(_pipe@7),
        priv@errors:assert_ok(_pipe@8)
    end,
    Session = begin
        _pipe@9 = priv@toml:get_string(Aoc_toml, [<<"session"/utf8>>]),
        _pipe@10 = priv@errors:map_error(
            _pipe@9,
            <<"Could not read \"session\" from aoc.toml"/utf8>>
        ),
        _pipe@11 = priv@errors:print_error(_pipe@10),
        priv@errors:assert_ok(_pipe@11)
    end,
    Showtime = case Aoc_toml_version of
        {ok, 2} ->
            _pipe@12 = priv@toml:get_bool(Aoc_toml, [<<"showtime"/utf8>>]),
            _pipe@13 = priv@errors:map_error(
                _pipe@12,
                <<"Could not read \"showtime\" from aoc.toml"/utf8>>
            ),
            _pipe@14 = priv@errors:print_error(_pipe@13),
            priv@errors:assert_ok(_pipe@14);

        _ ->
            _pipe@15 = priv@toml:get_string(Aoc_toml, [<<"showtime"/utf8>>]),
            _pipe@16 = gleam@result:map(
                _pipe@15,
                fun(Bool_string) -> case Bool_string of
                        <<"True"/utf8>> ->
                            true;

                        _ ->
                            false
                    end end
            ),
            _pipe@17 = priv@errors:map_error(
                _pipe@16,
                <<"Could not read \"showtime\" from aoc.toml"/utf8>>
            ),
            _pipe@18 = priv@errors:print_error(_pipe@17),
            priv@errors:assert_ok(_pipe@18)
    end,
    Test_folder = adglent:get_test_folder(Day@1),
    Test_file = <<<<<<Test_folder/binary, "/day"/utf8>>/binary, Day@1/binary>>/binary,
        "_test.gleam"/utf8>>,
    _pipe@19 = simplifile:create_directory_all(Test_folder),
    _pipe@20 = priv@errors:map_error(
        _pipe@19,
        <<<<"Could not create folder \""/utf8, Test_folder/binary>>/binary,
            "\""/utf8>>
    ),
    _pipe@21 = priv@errors:print_error(_pipe@20),
    priv@errors:assert_ok(_pipe@21),
    Testfile_template = case Showtime of
        true ->
            <<"
import gleam/list
import showtime/tests/should
import adglent.{type Example, Example}
import day{{ day }}/solve

type Problem1AnswerType =
  String

type Problem2AnswerType =
  String

/// Add examples for part 1 here:
/// ```gleam
///const part1_examples: List(Example(Problem1AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part1_examples: List(Example(Problem1AnswerType)) = []

/// Add examples for part 2 here:
/// ```gleam
///const part2_examples: List(Example(Problem2AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part2_examples: List(Example(Problem2AnswerType)) = []

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.not_equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}

"/utf8>>;

        false ->
            <<"
import gleam/list
import gleeunit/should
import adglent.{type Example, Example}
import day{{ day }}/solve

type Problem1AnswerType =
  String

type Problem2AnswerType =
  String

/// Add examples for part 1 here:
/// ```gleam
///const part1_examples: List(Example(Problem1AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part1_examples: List(Example(Problem1AnswerType)) = []

/// Add examples for part 2 here:
/// ```gleam
///const part2_examples: List(Example(Problem2AnswerType)) = [Example(\"some input\", \"\")]
/// ```
const part2_examples: List(Example(Problem2AnswerType)) = []

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.not_equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}

"/utf8>>
    end,
    _pipe@22 = priv@template:render(
        Testfile_template,
        [{<<"day"/utf8>>, Day@1}]
    ),
    _pipe@23 = create_file_if_not_present(_pipe@22, Test_file),
    _pipe@24 = priv@errors:print_result(_pipe@23),
    priv@errors:assert_ok(_pipe@24),
    Solutions_folder = <<"src/day"/utf8, Day@1/binary>>,
    Solution_file = <<Solutions_folder/binary, "/solve.gleam"/utf8>>,
    _pipe@25 = simplifile:create_directory_all(Solutions_folder),
    _pipe@26 = priv@errors:map_error(
        _pipe@25,
        <<<<"Could not create folder \""/utf8, Solutions_folder/binary>>/binary,
            "\""/utf8>>
    ),
    _pipe@27 = priv@errors:print_error(_pipe@26),
    priv@errors:assert_ok(_pipe@27),
    _pipe@28 = priv@template:render(
        <<"
import adglent.{First, Second}
import gleam/io

pub fn part1(input: String) {
  todo as \"Implement solution to part 1\"
}

pub fn part2(input: String) {
  todo as \"Implement solution to part 2\"
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input(\"{{ day }}\")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
"/utf8>>,
        [{<<"day"/utf8>>, Day@1}]
    ),
    _pipe@29 = create_file_if_not_present(_pipe@28, Solution_file),
    _pipe@30 = priv@errors:print_result(_pipe@29),
    priv@errors:assert_ok(_pipe@30),
    _pipe@31 = create_file_if_not_present(
        <<"input.txt"/utf8>>,
        <<Solutions_folder/binary, "/.gitignore"/utf8>>
    ),
    _pipe@32 = priv@errors:print_result(_pipe@31),
    priv@errors:assert_ok(_pipe@32),
    Input = begin
        _pipe@33 = priv@aoc_client:get_input(Year, Day@1, Session),
        _pipe@34 = priv@errors:map_error(
            _pipe@33,
            <<"Error when fetching input"/utf8>>
        ),
        _pipe@35 = priv@errors:print_error(_pipe@34),
        priv@errors:assert_ok(_pipe@35)
    end,
    _pipe@36 = Input,
    _pipe@37 = gleam@string:trim(_pipe@36),
    _pipe@38 = create_file_if_not_present(
        _pipe@37,
        <<Solutions_folder/binary, "/input.txt"/utf8>>
    ),
    _pipe@39 = priv@errors:print_result(_pipe@38),
    priv@errors:assert_ok(_pipe@39).
