## 2024 Solutions

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

---

1. [Historian Hysteria](https://adventofcode.com/2024/day/1) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_1.gleam), [Racket](/racket/aoc2024/day-01.rkt)) ⭐ ♥️♥️ 

   *Find the differences of pairs of numbers; find how often numbers in one list appear in another list.* Not much to say; pretty much a test of whether you're familiar with your language's standard library for list/array operations.

2. [Red-Nosed Reports](https://adventofcode.com/2024/day/2) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_2.gleam), [Racket](/racket/aoc2024/day-02.rkt)) ⭐ ♥️♥️♥️ 
   
   *Check if number sequences satisfy a condition; figure out if they can be fixed by removing one number.* There's probably a nice dynamic programming solution to this, but the solution set's small enough that generating all the possibilities is fine.

3. [Mull It Over](https://adventofcode.com/2024/day/3) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_3.gleam), [Racket](/racket/aoc2024/day-03.rkt)) ⭐ ♥️♥️

   *Parse some noisy code, including conditional statements.* I saw some people either solve it entirely with regexp or entirely by parsing the string themselves; I split the difference and used regexp to tokenize the input.

4. [Ceres Search](https://adventofcode.com/2024/day/4) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_4.gleam), [Racket](/racket/aoc2024/day-04.rkt)) ⭐ ♥️♥️♥️ 
   
   *Find a repeated word in a word search, then find a repeated pattern of characters.* Turns out I had already solved [a similar problem](https://exercism.org/tracks/elixir/exercises/word-search/solutions/jimpjorps) in Elixir on Exercism, so I adapted my solution from that. It's cool to be able to draw on the library of past code I've written.

5. [Print Queue](https://adventofcode.com/2024/day/5) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_5.gleam), [Racket](/racket/aoc2024/day-05.rkt)) ⭐⭐ ♥️♥️ 
   
   *Sort a list based on rules for how pairs should be ordered.* I wrote the world's worst bubble search for this one before realizing I could just offload the sorting to the standard library and write a simple comparator instead.

6. [Guard Gallivant](https://adventofcode.com/2024/day/6) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_6.gleam), [Racket](/racket/aoc2024/day-06.rkt)) ⭐⭐⭐ ♥️♥️♥️
   
   *Trace a guard's path through a grid of obstacles; figure out where to put new obstacles to make the guard loop infinitely.* Grid movement problems, my beloved.  I had one little quirk with my movement behavior that I had to talk through with someone to debug, but otherwise this was very familiar territory.
   
7. [Bridge Repair](https://adventofcode.com/2024/day/7) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_7.gleam), [Racket](/racket/aoc2024/day-07.rkt)) ⭐⭐ ♥️♥️♥️♥️
   
   *Decide if a list of numbers can be combined with math operations to reach a target answer.* I like this one because it admits multiple, increasingly optimal solutions: you can generate all the possible operation combinations and check them all, you can use depth-first search to eliminate impossible branches, or you can use some math facts and work backwards to eliminate even more impossible operations.

8. [Resonant Collinearity](https://adventofcode.com/2024/day/8) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_8.gleam), [Racket](/racket/aoc2024/day-08.rkt)) ⭐ ♥️♥️♥️
   
   *Antennas make resonance points. Find them all.* Another grid problem, and a pretty straightforward one too. Not much to say about this one; the only real difficulty was making sure that I understood the rules of the game before I started on it.

9.   [Disk Fragmenter](https://adventofcode.com/2024/day/9) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_9.gleam), [Racket](/racket/aoc2024/day-09.rkt)) ⭐⭐⭐ ♥️♥️♥️
    
     *Defragment a hard drive, first by moving blocks, then by moving entire files.* Coming up with a working algorithm for achieving this took some thought, but once I had the outline of what I wanted to, putting the pieces together wasn't too bad, especially with the help of Gleam's static types to keep all the list operations straight. I probably should've done this with an array instead, but this is about the part of AoC where I start focusing more on just getting a solution than getting something elegant or efficient.

10.  [Hoof It](https://adventofcode.com/2024/day/10) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_10.gleam), [Racket](/racket/aoc2024/day-10.rkt)) ⭐⭐ ♥️♥️♥️
    
     *Rate hiking trails in various ways.* I think I've finally done depth-first searches in AoC enough that I know how to do them right off the bat instead of having to fumble around online trying to translate pseudocode.  Another pretty standard "find something interesting about a grid of numbers" problem.