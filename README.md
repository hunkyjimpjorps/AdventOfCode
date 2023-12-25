# Jimpjorps Does Advent of Code

My solutions for [Advent of Code](https://adventofcode.com/).  

Solutions are in:
* __2021__: [Racket](https://racket-lang.org/), with some in [Elixir](https://elixir-lang.org/)
* __2022__: Racket
* __2023__: [Gleam](https://gleam.run/) and Racket

## 2023 Solutions

### Difficulty rating
* ⭐ I was able to write a straightforward solution without any problems
* ⭐⭐ I ran into a few hurdles or bugs, but it eventually came together pretty smoothly
* ⭐⭐⭐ I needed to do some research to figure out how to do this one, or it took me many abortive tries to figure out a working method
* ⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else discuss how they solved it
* ⭐⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else's code

### Enjoyment rating
* ♥️ Really annoying; the problem statement was confusing, or the solution didn't feel worth all the effort, or Part 2 was unsolvable without knowing obscure theory
* ♥️♥️ It was *okay*, I guess (usually because there's more parsing than solving)
* ♥️♥️♥️ An average Advent of Code problem; not bad but not fantastic either
* ♥️♥️♥️♥️ Fun and interesting to work through; I spent more time than average on tweaking and improving the solution because I was enjoying myself
* ♥️♥️♥️♥️♥️ My favorite one of the year; it's the kind of problem I enjoy solving and the solution was elegant or interesting

| Name                                                                   | Racket                                     | Gleam                                    | Difficulty | Enjoyment  | Involves |
| ---------------------------------------------------------------------- | :----------------------------------------: | :--------------------------------------: | ---------: | :--------- | -------- |
| [Trebuchet?!](https://adventofcode.com/2023/day/1)                     | [1](/aoc2023-other/day-01/day-01.rkt)  | [1](/aoc2023/src/day1/solve.gleam)   | ⭐⭐⭐        | ♥️♥️       | regex
| [Cube Conundrum](https://adventofcode.com/2023/day/2)                  | [2](/aoc2023-other/day-02/day-02.rkt)  | [2](/aoc2023/src/day2/solve.gleam)   | ⭐          | ♥️♥️♥️     | parsing, higher-order functions
| [Gear Ratios](https://adventofcode.com/2023/day/3)                     | [3](/aoc2023-other/day-03/day-03.rkt)  | [3](/aoc2023/src/day3/solve.gleam)   | ⭐⭐⭐        | ♥️♥️       | arrays
| [Scratchcards](https://adventofcode.com/2023/day/4)                    | [4](/aoc2023-other/day-04/day-04.rkt)  | [4](/aoc2023/src/day4/solve.gleam)   | ⭐          | ♥️♥️♥️     | hashmaps
| [If You Give a Seed a Fertilizer](https://adventofcode.com/2023/day/5) | [5](/aoc2023-other/day-05/day-05.rkt)  | [5](/aoc2023/src/day5/solve.gleam)   | ⭐⭐         | ♥️         | sparse ranges
| [Wait For It](https://adventofcode.com/2023/day/6)                     | [6](/aoc2023-other/day-06/day-06.rkt)  | [6](/aoc2023/src/day6/solve.gleam)   | ⭐          | ♥️♥️       | algebra, root-finding
| [Camel Cards](https://adventofcode.com/2023/day/7)                     | [7](/aoc2023-other/day-07/day-07.rkt)  | [7](/aoc2023/src/day7/solve.gleam)   | ⭐          | ♥️♥️♥️♥️   | pattern matching
| [Haunted Wasteland](https://adventofcode.com/2023/day/8)               | [8](/aoc2023-other/day-08/day-08.rkt)  | [8](/aoc2023/src/day8/solve.gleam)   | ⭐⭐         | ♥️         | state machines, number theory
| [Mirage Maintenance](https://adventofcode.com/2023/day/9)              | [9](/aoc2023-other/day-09/day-09.rkt)  | [9](/aoc2023/src/day9/solve.gleam)   | ⭐          | ♥️♥️       | numerical methods
| [Pipe Maze](https://adventofcode.com/2023/day/10)                      | [10](/aoc2023-other/day-10/day-10.rkt) | [10](/aoc2023/src/day10/solve.gleam) | ⭐⭐         | ♥️♥️♥️     | DFS, point-in-polygon problem
| [Cosmic Expansion](https://adventofcode.com/2023/day/11)               | [11](/aoc2023-other/day-11/day-11.rkt) | [11](/aoc2023/src/day11/solve.gleam) | ⭐⭐         | ♥️♥️       | parsing, sparse matrices
| [Hot Springs](https://adventofcode.com/2023/day/12)                    | [12](/aoc2023-other/day-12/day-12.rkt) | [12](/aoc2023/src/day12/solve.gleam) | ⭐⭐⭐⭐       | ♥️♥️♥️♥️   | dynamic programming
| [Point of Incidence](https://adventofcode.com/2023/day/13)             | [13](/aoc2023-other/day-13/day-13.rkt) | [13](/aoc2023/src/day13/solve.gleam) | ⭐⭐         | ♥️♥️♥️     | recursion
| [Parabolic Reflector Dish](https://adventofcode.com/2023/day/14)       | [14](/aoc2023-other/day-14/day-14.rkt) | [14](/aoc2023/src/day14/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️♥️   | simulation
| [Lens Library](https://adventofcode.com/2023/day/15)                   | [15](/aoc2023-other/day-15/day-15.rkt) | [15](/aoc2023/src/day15/solve.gleam) | ⭐          | ♥️♥️       | hashmaps
| [The Floor Will Be Lava](https://adventofcode.com/2023/day/16)         | [16](/aoc2023-other/day-16/day-16.rkt) | [16](/aoc2023/src/day16/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | simulation
| [Clumsy Crucible](https://adventofcode.com/2023/day/17)                | [17](/aoc2023-other/day-17/day-17.rkt) | ⛔                                  | ⭐⭐⭐⭐⭐      | ♥️♥️♥️     | BFS, Dijkstra
| [Lavaduct Lagoon](https://adventofcode.com/2023/day/18)                | [18](/aoc2023-other/day-18/day-18.rkt) | [18](/aoc2023/src/day18/solve.gleam) | ⭐          | ♥️♥️♥️♥️   | geometry
| [Aplenty](https://adventofcode.com/2023/day/19)                        | [19](/aoc2023-other/day-19/day-19.rkt) | [19](/aoc2023/src/day19/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | sparse ranges
| [Pulse Propagation](https://adventofcode.com/2023/day/20)              | [20](/aoc2023-other/day-20/day-20.rkt) | [20](/aoc2023/src/day20/solve.gleam) | ⭐⭐⭐⭐       | ♥️♥️         | simulation, number theory
| [Step Counter](https://adventofcode.com/2023/day/21)                   | [21](/aoc2023-other/day-21/day-21.rkt) | ⛔                                  | ⭐⭐⭐⭐       | ♥️♥️         | cellular automata
| [Sand Slabs](https://adventofcode.com/2023/day/22)                     | [22](/aoc2023-other/day-22/day-22.rkt) | [22](/aoc2023/src/day22/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️♥️♥️ | simulation, BFS
| [A Long Walk](https://adventofcode.com/2023/day/23)                    | [23](/aoc2023-other/day-23/day-23.rkt) | [23](/aoc2023/src/day23/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | DFS
| [Never Tell Me The Odds](https://adventofcode.com/2023/day/24) | [24-1](/aoc2023-other/day-24/day-24.rkt) [24-2](/aoc2023-other/day-24/day-24.ipynb) | ⛔ | ⭐⭐⭐⭐ | ♥️♥️♥️ | algebra, linear equations, constraint solving
| [](https://adventofcode.com/2023/day/25)                               | [25](/aoc2023-other/day-25/day-25.rkt) | [25](/aoc2023/src/day25/solve.gleam) |            |            |
