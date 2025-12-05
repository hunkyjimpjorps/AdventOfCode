# 2025 Solutions

## Difficulty rating

* ⭐ I was able to write a straightforward solution without any problems
* ⭐⭐ I ran into a few hurdles or bugs, but it eventually came together pretty smoothly
* ⭐⭐⭐ I needed to do some research to figure out how to do this one, or it took me many abortive tries to figure out a working method
* ⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else discuss how they solved it
* ⭐⭐⭐⭐⭐ I couldn't figure this one out without seeing someone else's code

## Enjoyment rating

* ♥️ Really annoying; the problem statement was confusing, or the solution didn't feel worth all the effort, or Part 2 was unsolvable without knowing obscure theory
* ♥️♥️ It was *okay*, I guess (usually because there's more parsing than solving)
* ♥️♥️♥️ An average Advent of Code problem; not bad but not fantastic either
* ♥️♥️♥️♥️ Fun and interesting to work through; I spent more time than average on tweaking and improving the solution because I was enjoying myself
* ♥️♥️♥️♥️♥️ My favorite one of the year; it's the kind of problem I enjoy solving and the solution was elegant or interesting

---

1. [Secret Entrance](https://adventofcode.com/2025/day/1) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_1.gleam), [Racket](/racket/aoc2025/day-01.rkt))  ⭐⭐ ♥️♥️

   *Spin a 0-99 dial.  How many times does it land on 0? How many times does it pass 0?*  A little rougher than usual for a day 1 problem, with a bunch of potential off-by-one pitfalls with modulo math.  The input's small enough that just simulating the dial click-by-click works in reasonable time, though.

2. [Gift Shop](https://adventofcode.com/2025/day/2) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_2.gleam) [(regex version)](/gleam/aoc2025/src/aoc_2025/day_2.gleam), [Racket](/racket/aoc2025/day-02.rkt)) ⭐ ♥️♥️♥️

   *How many ID numbers in these ranges are a sequence of digits repeated twice?  How many are a sequence of repeated digits in general?* The regex version was pretty straightforward, but I decided to go the extra mile and write a math-only version with no string manipulation, too.

3. [Lobby](https://adventofcode.com/2025/day/3) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_3.gleam), [Racket](/racket/aoc2025/day-03.rkt)) ⭐⭐ ♥️♥️♥️

   *What's the biggest two-digit number that can be extracted from this sequence of digits?  What's the biggest 12-digit number?* Implementing the general strategy for selecting the digits wasn't too bad, but it took some thought to figure out a way that didn't require constantly traversing the linked list or resorting to indexed addressing.

4. [Printing Department](https://adventofcode.com/2025/day/4) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_4.gleam), [Racket](/racket/aoc2025/day-04.rkt)) ⭐ ♥️♥️♥️

   *How many rolls of paper in this warehouse are removable right now?  If we keep removing all the removable rolls, how many can we remove in all?* The first grid problem; fundamentally it's a cellular automaton where cells can die but no new cells are created.

5. [Cafeteria](https://adventofcode.com/2025/day/5) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_5.gleam), [Racket](/racket/aoc2025/day-05.rkt)) ⭐ ♥️♥️

   *How many of these provided values fall within these ranges?  How many values are in these ranges in all?*   The first part 2 this year where the values are too big to just iterate over, but otherwise I can't think of anything notable to mention.