 1: # Jimpjorps Does Advent of Code
 2: 
 3: My solutions for [Advent of Code](https://adventofcode.com/).  
 4: 
 5: Solutions are in:
 6: 
 7: * __2021__: [Racket](https://racket-lang.org/), with some in [Elixir](https://elixir-lang.org/)
 8: * __2022__: Racket
 9: * __2023__: [Gleam](https://gleam.run/) and Racket
10: 
11: ## 2023 Solutions
12: 
13: ### Difficulty rating
14: 
15: * ⭐ I was able to write a straightforward solution without any problems
16: * ⭐⭐ I ran into a few hurdles or bugs, but it eventually came together pretty smoothly
17: * ⭐⭐⭐ I needed to do some research to figure out how to do this one, or it took me many abortive tries to figure out a working method
18: * ⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else discuss how they solved it
19: * ⭐⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else's code
20: 
21: ### Enjoyment rating
22: 
23: * ♥️ Really annoying; the problem statement was confusing, or the solution didn't feel worth all the effort, or Part 2 was unsolvable without knowing obscure theory
24: * ♥️♥️ It was *okay*, I guess (usually because there's more parsing than solving)
25: * ♥️♥️♥️ An average Advent of Code problem; not bad but not fantastic either
26: * ♥️♥️♥️♥️ Fun and interesting to work through; I spent more time than average on tweaking and improving the solution because I was enjoying myself
27: * ♥️♥️♥️♥️♥️ My favorite one of the year; it's the kind of problem I enjoy solving and the solution was elegant or interesting
28: 
29: | Name                                                                   |                                       Racket                                        |                Gleam                 | Difficulty | Enjoyment | Involves                                      |
30: | ---------------------------------------------------------------------- | :---------------------------------------------------------------------------------: | :----------------------------------: | ---------: | :-------- | --------------------------------------------- |
31: | [Trebuchet?!](https://adventofcode.com/2023/day/1)                     |                        [1](/aoc2023-other/day-01/day-01.rkt)                        |  [1](/aoc2023/src/day1/solve.gleam)  |        ⭐⭐⭐ | ♥️♥️        | regex                                         |
32: | [Cube Conundrum](https://adventofcode.com/2023/day/2)                  |                        [2](/aoc2023-other/day-02/day-02.rkt)                        |  [2](/aoc2023/src/day2/solve.gleam)  |          ⭐ | ♥️♥️♥️       | parsing, higher-order functions               |
33: | [Gear Ratios](https://adventofcode.com/2023/day/3)                     |                        [3](/aoc2023-other/day-03/day-03.rkt)                        |  [3](/aoc2023/src/day3/solve.gleam)  |        ⭐⭐⭐ | ♥️♥️        | arrays                                        |
34: | [Scratchcards](https://adventofcode.com/2023/day/4)                    |                        [4](/aoc2023-other/day-04/day-04.rkt)                        |  [4](/aoc2023/src/day4/solve.gleam)  |          ⭐ | ♥️♥️♥️       | hashmaps                                      |
35: | [If You Give a Seed a Fertilizer](https://adventofcode.com/2023/day/5) |                        [5](/aoc2023-other/day-05/day-05.rkt)                        |  [5](/aoc2023/src/day5/solve.gleam)  |         ⭐⭐ | ♥️         | sparse ranges                                 |
36: | [Wait For It](https://adventofcode.com/2023/day/6)                     |                        [6](/aoc2023-other/day-06/day-06.rkt)                        |  [6](/aoc2023/src/day6/solve.gleam)  |          ⭐ | ♥️♥️        | algebra, root-finding                         |
37: | [Camel Cards](https://adventofcode.com/2023/day/7)                     |                        [7](/aoc2023-other/day-07/day-07.rkt)                        |  [7](/aoc2023/src/day7/solve.gleam)  |          ⭐ | ♥️♥️♥️♥️      | pattern matching                              |
38: | [Haunted Wasteland](https://adventofcode.com/2023/day/8)               |                        [8](/aoc2023-other/day-08/day-08.rkt)                        |  [8](/aoc2023/src/day8/solve.gleam)  |         ⭐⭐ | ♥️         | state machines, number theory                 |
39: | [Mirage Maintenance](https://adventofcode.com/2023/day/9)              |                        [9](/aoc2023-other/day-09/day-09.rkt)                        |  [9](/aoc2023/src/day9/solve.gleam)  |          ⭐ | ♥️♥️        | numerical methods                             |
40: | [Pipe Maze](https://adventofcode.com/2023/day/10)                      |                       [10](/aoc2023-other/day-10/day-10.rkt)                        | [10](/aoc2023/src/day10/solve.gleam) |         ⭐⭐ | ♥️♥️♥️       | DFS, point-in-polygon problem                 |
41: | [Cosmic Expansion](https://adventofcode.com/2023/day/11)               |                       [11](/aoc2023-other/day-11/day-11.rkt)                        | [11](/aoc2023/src/day11/solve.gleam) |         ⭐⭐ | ♥️♥️        | parsing, sparse matrices                      |
42: | [Hot Springs](https://adventofcode.com/2023/day/12)                    |                       [12](/aoc2023-other/day-12/day-12.rkt)                        | [12](/aoc2023/src/day12/solve.gleam) |       ⭐⭐⭐⭐ | ♥️♥️♥️♥️      | dynamic programming                           |
43: | [Point of Incidence](https://adventofcode.com/2023/day/13)             |                       [13](/aoc2023-other/day-13/day-13.rkt)                        | [13](/aoc2023/src/day13/solve.gleam) |         ⭐⭐ | ♥️♥️♥️       | recursion                                     |
44: | [Parabolic Reflector Dish](https://adventofcode.com/2023/day/14)       |                       [14](/aoc2023-other/day-14/day-14.rkt)                        | [14](/aoc2023/src/day14/solve.gleam) |        ⭐⭐⭐ | ♥️♥️♥️♥️      | simulation                                    |
45: | [Lens Library](https://adventofcode.com/2023/day/15)                   |                       [15](/aoc2023-other/day-15/day-15.rkt)                        | [15](/aoc2023/src/day15/solve.gleam) |          ⭐ | ♥️♥️        | hashmaps                                      |
46: | [The Floor Will Be Lava](https://adventofcode.com/2023/day/16)         |                       [16](/aoc2023-other/day-16/day-16.rkt)                        | [16](/aoc2023/src/day16/solve.gleam) |        ⭐⭐⭐ | ♥️♥️♥️       | simulation                                    |
47: | [Clumsy Crucible](https://adventofcode.com/2023/day/17)                |                       [17](/aoc2023-other/day-17/day-17.rkt)                        |                  ⛔                   |      ⭐⭐⭐⭐⭐ | ♥️♥️♥️       | BFS, Dijkstra                                 |
48: | [Lavaduct Lagoon](https://adventofcode.com/2023/day/18)                |                       [18](/aoc2023-other/day-18/day-18.rkt)                        | [18](/aoc2023/src/day18/solve.gleam) |          ⭐ | ♥️♥️♥️♥️      | geometry                                      |
49: | [Aplenty](https://adventofcode.com/2023/day/19)                        |                       [19](/aoc2023-other/day-19/day-19.rkt)                        | [19](/aoc2023/src/day19/solve.gleam) |        ⭐⭐⭐ | ♥️♥️♥️       | sparse ranges                                 |
50: | [Pulse Propagation](https://adventofcode.com/2023/day/20)              |                       [20](/aoc2023-other/day-20/day-20.rkt)                        | [20](/aoc2023/src/day20/solve.gleam) |       ⭐⭐⭐⭐ | ♥️♥️        | simulation, number theory                     |
51: | [Step Counter](https://adventofcode.com/2023/day/21)                   |                       [21](/aoc2023-other/day-21/day-21.rkt)                        |                  ⛔                   |       ⭐⭐⭐⭐ | ♥️♥️        | cellular automata                             |
52: | [Sand Slabs](https://adventofcode.com/2023/day/22)                     |                       [22](/aoc2023-other/day-22/day-22.rkt)                        | [22](/aoc2023/src/day22/solve.gleam) |        ⭐⭐⭐ | ♥️♥️♥️♥️♥️     | simulation, BFS                               |
53: | [A Long Walk](https://adventofcode.com/2023/day/23)                    |                       [23](/aoc2023-other/day-23/day-23.rkt)                        | [23](/aoc2023/src/day23/solve.gleam) |        ⭐⭐⭐ | ♥️♥️♥️       | DFS                                           |
54: | [Never Tell Me The Odds](https://adventofcode.com/2023/day/24)         | [24-1](/aoc2023-other/day-24/day-24a.rkt) [24-2](/aoc2023-other/day-24/day-24b.rkt) |                  ⛔                   |       ⭐⭐⭐⭐ | ♥️♥️♥️       | algebra, linear equations, constraint solving |
55: | [Snowverload](https://adventofcode.com/2023/day/25)                    |                       [25](/aoc2023-other/day-25/day-25.rkt)                        |                  ⛔                   |        ⭐⭐⭐ | ♥️♥️♥️♥️      | graphs, visualization                         |
56: 
