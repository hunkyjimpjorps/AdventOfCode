# adglent

[![Package Version](https://img.shields.io/hexpm/v/adglent)](https://hex.pm/packages/adglent)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/adglent/)

## About

`adglent` is a Gleam library which can be used to setup testing code and a template for implementing solution to [Advent of code](https://adventofcode.com/) problems.

> NOTE: `adglent` **only** supports `erlang` target (default) for Gleam.

## Prerequisites

`adglent` is written in `gleam` and runs and tests solutions written in Gleam. Read more about `gleam` at [gleam.run](https://gleam.run).

The easiest way to install `gleam` is to use `asdf`:

1. Install `asdf` according to the instructions at the [asdf website](https://asdf-vm.com/)
2. Install the gleam asdf plugin: `asdf plugin-add gleam`
3. Install the latest `asdf install gleam latest`
4. Use the latest gleam version globally: `asdf global gleam latest`

> HINT: `asdf` can manage multiple versions of gleam and the version can be set globally and also locally (`asdf local gleam <VERSION>`) to use a specific gleam version in a project.

## Installation

Start a new gleam project for your AOC soluctions with `gleam new`. In the project folder run:

```sh
gleam add --dev adglent
```

## Usage

### Initializing

First log in to [Advent of code](https://adventofcode.com/) and copy your personal `session-cookie`. The value can be found using developer tools in the browser (in Chrome: "Application->Cookies->https://adventofcode.com->session" and copy the Cookie-value)

```sh
gleam run -m adglent/init
```

Input the AOC year, you personal AOC session cookie and select if `showtime` should be used for tests (otherwise it will assume the project uses `gleeunit` as is default for `gleam new <project>`)

> NOTE: `showtime` is an alternate gleam test-runner. It is still quite new and havn't been tested in as many project as `gleeunit`. It has a different way of formatting the test-results and also supports the possibility to run specific test-modules (which can be useful in AOC). `showtime` is a standalone project but have been embedded into `adglent`.

### Add day

To start working on the solution for a specific day run:

```sh
gleam run -m adglent/day <NUM>
```

Where `<NUM>` is the day number of the day you want to solve a problem for.

> Example (start solving 1st of December):
>
> ```sh
> gleam run -m adglent/day 1
> ```

Adding a day will add tests in `test/day<NUM>/day<NUM>_test.gleam`and a `src/day<NUM>/solve.gleam` file where the solution can be implemented.

Furthermore it will also download the input for the problem to `src/day<NUM>/input.txt`

Before running the tests you need to provide one or more example. These can be found in the problem description for that day at the AOC website.

Add an example to a part of the problem by adding examples to the `part1_examples` or `part2_examples` lists.

> Example (input "Hello Joe!" should give answer 613411):
>
> ```gleam
> const part1_examples: List(Example(Problem1AnswerType)) = [
>   Example("Hello Joe!", "613411"),
> ]
> ```

The type of the answer for a part can be adjusted if needed by changing the type aliases `Problem1AnswerType` / `Problem2AnswerType`. Note that this will change the type that the `part1` / `part2` functions in `solve.gleam` expect to return.

### Testing

To test all days in the project use:

```sh
gleam test
```

If you are using `showtime` you can test a single day by running:

```sh
gleam test -- --modules=day<NUM>/day<NUM>_test
```

> Example (test solution for 1st of December):
>
> ```sh
> gleam test -- modules=day1/day1_test
> ```

### Get the answer

To get the (hopefully correct) answer after the tests are ok run:

```sh
gleam run -m day<NUM>/solve <PART>
```

where `<NUM>` is the day to solve and `<PART>` is the part of the problem (1 or 2) to solve.

This will run the solver and print the answer to stdout.

### Module documentation

Module documentation can be found at <https://hexdocs.pm/adglent>.
