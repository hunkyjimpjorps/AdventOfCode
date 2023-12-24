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

| Day | Name                                                                   | Racket                                     | Gleam                                    | Difficulty | Enjoyment  | Involves |
| --- | ---------------------------------------------------------------------- | :----------------------------------------: | :--------------------------------------: | ---------: | :--------- | -------- |
| 1   | [Trebuchet?!](https://adventofcode.com/2023/day/1)                     | [Day 1](/aoc2023-other/day-01/day-01.rkt)  | [Day 1](/aoc2023/src/day1/solve.gleam)   | ⭐⭐⭐        | ♥️♥️       | regex
| 2   | [Cube Conundrum](https://adventofcode.com/2023/day/2)                  | [Day 2](/aoc2023-other/day-02/day-02.rkt)  | [Day 2](/aoc2023/src/day2/solve.gleam)   | ⭐          | ♥️♥️♥️     | parsing, higher-order functions
| 3   | [Gear Ratios](https://adventofcode.com/2023/day/3)                     | [Day 3](/aoc2023-other/day-03/day-03.rkt)  | [Day 3](/aoc2023/src/day3/solve.gleam)   | ⭐⭐⭐        | ♥️♥️       | arrays
| 4   | [Scratchcards](https://adventofcode.com/2023/day/4)                    | [Day 4](/aoc2023-other/day-04/day-04.rkt)  | [Day 4](/aoc2023/src/day4/solve.gleam)   | ⭐          | ♥️♥️♥️     | hashmaps
| 5   | [If You Give a Seed a Fertilizer](https://adventofcode.com/2023/day/5) | [Day 5](/aoc2023-other/day-05/day-05.rkt)  | [Day 5](/aoc2023/src/day5/solve.gleam)   | ⭐⭐         | ♥️         | sparse ranges
| 6   | [Wait For It](https://adventofcode.com/2023/day/6)                     | [Day 6](/aoc2023-other/day-06/day-06.rkt)  | [Day 6](/aoc2023/src/day6/solve.gleam)   | ⭐          | ♥️♥️       | algebra, root-finding
| 7   | [Camel Cards](https://adventofcode.com/2023/day/7)                     | [Day 7](/aoc2023-other/day-07/day-07.rkt)  | [Day 7](/aoc2023/src/day7/solve.gleam)   | ⭐          | ♥️♥️♥️♥️   | pattern matching
| 8   | [Haunted Wasteland](https://adventofcode.com/2023/day/8)               | [Day 8](/aoc2023-other/day-08/day-08.rkt)  | [Day 8](/aoc2023/src/day8/solve.gleam)   | ⭐⭐         | ♥️         | state machines, number theory
| 9   | [Mirage Maintenance](https://adventofcode.com/2023/day/9)              | [Day 9](/aoc2023-other/day-09/day-09.rkt)  | [Day 9](/aoc2023/src/day9/solve.gleam)   | ⭐          | ♥️♥️       | numerical methods
| 10  | [Pipe Maze](https://adventofcode.com/2023/day/10)                      | [Day 10](/aoc2023-other/day-10/day-10.rkt) | [Day 10](/aoc2023/src/day10/solve.gleam) | ⭐⭐         | ♥️♥️♥️     | DFS, point-in-polygon problem
| 11  | [Cosmic Expansion](https://adventofcode.com/2023/day/11)               | [Day 11](/aoc2023-other/day-11/day-11.rkt) | [Day 11](/aoc2023/src/day11/solve.gleam) | ⭐⭐         | ♥️♥️       | parsing, sparse matrices
| 12  | [Hot Springs](https://adventofcode.com/2023/day/12)                    | [Day 12](/aoc2023-other/day-12/day-12.rkt) | [Day 12](/aoc2023/src/day12/solve.gleam) | ⭐⭐⭐⭐       | ♥️♥️♥️♥️   | dynamic programming
| 13  | [Point of Incidence](https://adventofcode.com/2023/day/13)             | [Day 13](/aoc2023-other/day-13/day-13.rkt) | [Day 13](/aoc2023/src/day13/solve.gleam) | ⭐⭐         | ♥️♥️♥️     | recursion
| 14  | [Parabolic Reflector Dish](https://adventofcode.com/2023/day/14)       | [Day 14](/aoc2023-other/day-14/day-14.rkt) | [Day 14](/aoc2023/src/day14/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️♥️   | simulation
| 15  | [Lens Library](https://adventofcode.com/2023/day/15)                   | [Day 15](/aoc2023-other/day-15/day-15.rkt) | [Day 15](/aoc2023/src/day15/solve.gleam) | ⭐          | ♥️♥️       | hashmaps
| 16  | [The Floor Will Be Lava](https://adventofcode.com/2023/day/16)         | [Day 16](/aoc2023-other/day-16/day-16.rkt) | [Day 16](/aoc2023/src/day16/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | simulation
| 17  | [Clumsy Crucible](https://adventofcode.com/2023/day/17)                | [Day 17](/aoc2023-other/day-17/day-17.rkt) | ⛔ | ⭐⭐⭐⭐⭐      | ♥️♥️♥️     | BFS, Dijkstra
| 18  | [Lavaduct Lagoon](https://adventofcode.com/2023/day/18)                | [Day 18](/aoc2023-other/day-18/day-18.rkt) | [Day 18](/aoc2023/src/day18/solve.gleam) | ⭐          | ♥️♥️♥️♥️   | geometry
| 19  | [Aplenty](https://adventofcode.com/2023/day/19)                        | [Day 19](/aoc2023-other/day-19/day-19.rkt) | [Day 19](/aoc2023/src/day19/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | sparse ranges
| 20  | [Pulse Propagation](https://adventofcode.com/2023/day/20)              | [Day 20](/aoc2023-other/day-20/day-20.rkt) | [Day 20](/aoc2023/src/day20/solve.gleam) | ⭐⭐⭐⭐       | ♥️♥️         | simulation, number theory
| 21  | [Step Counter](https://adventofcode.com/2023/day/21)                   | [Day 21](/aoc2023-other/day-21/day-21.rkt) | ⛔ | ⭐⭐⭐⭐       | ♥️♥️         | cellular automata
| 22  | [Sand Slabs](https://adventofcode.com/2023/day/22)                     | [Day 22](/aoc2023-other/day-22/day-22.rkt) | [Day 22](/aoc2023/src/day22/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️♥️♥️ | simulation, BFS
| 23  | [A Long Walk](https://adventofcode.com/2023/day/23)                    | [Day 23](/aoc2023-other/day-23/day-23.rkt) | [Day 23](/aoc2023/src/day23/solve.gleam) | ⭐⭐⭐        | ♥️♥️♥️     | DFS
| 24  | [](https://adventofcode.com/2023/day/24)                               | [Day 24](/aoc2023-other/day-24/day-24.rkt) | [Day 24](/aoc2023/src/day24/solve.gleam) |            |            |
| 25  | [](https://adventofcode.com/2023/day/25)                               | [Day 25](/aoc2023-other/day-25/day-25.rkt) | [Day 25](/aoc2023/src/day25/solve.gleam) |            |            |
