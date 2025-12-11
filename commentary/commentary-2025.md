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

      *Spin a 0-99 dial.  How many times does it land on 0? How many times does it pass 0?*

      A little rougher than usual for a day 1 problem, with a bunch of potential off-by-one pitfalls with modulo math.  The input's small enough that just simulating the dial click-by-click works in reasonable time, though.

2. [Gift Shop](https://adventofcode.com/2025/day/2) ([Gleam (numerical version)](/gleam/aoc2025/src/aoc_2025/day_2.gleam), [Gleam (regex version)](/gleam/aoc2025/src/aoc_2025/day_2.gleam), [Racket](/racket/aoc2025/day-02.rkt)) ⭐ ♥️♥️♥️

      *How many ID numbers in these ranges are a sequence of digits repeated twice?  How many are a sequence of repeated digits in general?*

      The regex version was pretty straightforward, but I decided to go the extra mile and write a math-only version with no string manipulation, too.

3. [Lobby](https://adventofcode.com/2025/day/3) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_3.gleam), [Racket](/racket/aoc2025/day-03.rkt)) ⭐⭐ ♥️♥️♥️

      *What's the biggest two-digit number that can be extracted from this sequence of digits?  What's the biggest 12-digit number?*

      Implementing the general strategy for selecting the digits wasn't too bad, but it took some thought to figure out a way that didn't require constantly traversing the linked list or resorting to indexed addressing.

4. [Printing Department](https://adventofcode.com/2025/day/4) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_4.gleam), [Racket](/racket/aoc2025/day-04.rkt)) ⭐ ♥️♥️♥️

      *How many rolls of paper in this warehouse are removable right now?  If we keep removing all the removable rolls, how many can we remove in all?*

      The first grid problem; fundamentally it's a cellular automaton where cells can die but no new cells are created.

5. [Cafeteria](https://adventofcode.com/2025/day/5) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_5.gleam), [Racket](/racket/aoc2025/day-05.rkt)) ⭐ ♥️♥️

      *How many of these provided values fall within these ranges?  How many values are in these ranges in all?* 

      The first part 2 this year where the values are too big to just iterate over, but otherwise I can't think of anything notable to mention.

6. [Trash Compactor](https://adventofcode.com/2025/day/6) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_6.gleam), [Racket](/racket/aoc2025/day-06.rkt)) ⭐ ♥️

      *Read these math problems. Read them a different way.*

      What if a problem was just parsing? 😔

7. [Laboratories](https://adventofcode.com/2025/day/7) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_7.gleam), [Racket](/racket/aoc2025/day-07.rkt)) ⭐⭐ ♥️♥️♥️♥️

      *How many splitters does this tachyon beam touch? How many possible paths can one tachyon travel?* 

      This is one of those problems where the part 2 solution is just a little tweak to the part 1 solution, which feels pretty satisfying to spot in the moment.  Also, it's a grid movement problem, which I've got my battle-tested suite of tools written over prior years ready for, so it feels good to get to apply those.

8. [Playground](https://adventofcode.com/2025/day/8) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_8.gleam), [Racket (graph version)](/racket/aoc2025/day-08.rkt), [Racket (hashmap version)](/racket/aoc2025/day-08-alt.rkt)) ⭐⭐⭐ ♥️♥️♥️

      *Hook up the nearest junction boxes 1,000 times. Hook up junction boxes until all 1,000 are connected.*   

      The key part to this problem is figuring out how to represent two networks of junction boxes being linked together.  Once I had a good process for that (explicitly using a graph in Racket, using a pair of `Dict`s in Gleam), everything else came quickly.

9. [Movie Theater](https://adventofcode.com/2025/day/9) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_9.gleam), [Racket](/racket/aoc2025/day-09.rkt)) ⭐⭐⭐ ♥️♥️♥️

      *Draw the biggest box between points on this list.  Draw the biggest box that fits in the polygon these points define.*   

      Priority queues are pretty useful for problems like this, with big solutions that can be ranked by some heuristic.  The geometry in this one was pretty basic since everything's orthogonal lines.

10. [Playground](https://adventofcode.com/2025/day/10) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_10.gleam), [Racket](/racket/aoc2025/day-10.rkt)) ⭐⭐⭐⭐ ♥️♥️♥️
    
      *Push buttons to turn off lights.  Push buttons to turn on electricity.*   

      Part 1 looks like it should've been a BFS, but a brute force search was easier and still pretty fast.  Part 2 is a linear optimization problem, and while there were some ways to cut down the solution space with linear algebra, everyone on the Gleam server decided it'd be more fun to just generate Z3 code and parse its output.  It's a pretty good trick to remember for future years (or at least until there's a better matrix math library for the BEAM).  I used [Rosette](https://docs.racket-lang.org/rosette-guide/index.html) for Racket and I think I'm finally starting to get a handle on how it works.

11. [Reactor](https://adventofcode.com/2025/day/11) ([Gleam](/gleam/aoc2025/src/aoc_2025/day_11.gleam), [Racket](/racket/aoc2025/day-11.rkt)) ⭐ ♥️♥️
    
      *Count how many ways your signal can travel to the end.  Count how many ways your signal can travel through three pieces of equipment.*   

      Surprisingly gentle after yesterday's; the problem description is very straightforward, the graph doesn't hide anything particularly nasty in it (there are a lot of paths, but it's a directed graph with no cycles, so no backtracking protection or cycle detection is necessary), and part 2 is just part 1's solution applied three times.  The one pitfall is that it needs memoization to complete in reasonable time, but at this point in AOC I'm applying memoization reflexively already.
