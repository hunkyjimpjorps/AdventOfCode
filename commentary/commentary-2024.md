# 2024 Solutions

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

1. [Historian Hysteria](https://adventofcode.com/2024/day/1) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_1.gleam), [Racket](/racket/aoc2024/day-01.rkt)) ⭐ ♥️♥️

   *Find the differences of pairs of numbers; find how often numbers in one list appear in another list.* Not much to say; pretty much a test of whether you're familiar with your language's standard library for list/array operations.

2. [Red-Nosed Reports](https://adventofcode.com/2024/day/2) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_2.gleam), [Racket](/racket/aoc2024/day-02.rkt)) ⭐ ♥️♥️♥️

   *Check if number sequences satisfy a condition; figure out if they can be fixed by removing one number.* There's probably a nice dynamic programming solution to this, but the solution set's small enough that generating all the possibilities is fine.

3. [Mull It Over](https://adventofcode.com/2024/day/3) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_3.gleam), [Racket](/racket/aoc2024/day-03.rkt)) ⭐ ♥️♥️

   *Parse some noisy code, including conditional statements.* I saw some people either solve it entirely with regexp or entirely by parsing the string themselves; I split the difference and used regexp to tokenize the input, then parsed the tokens.

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

9. [Disk Fragmenter](https://adventofcode.com/2024/day/9) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_9.gleam), [Racket](/racket/aoc2024/day-09.rkt)) ⭐⭐⭐ ♥️♥️♥️♥️

   *Defragment a hard drive, first by moving blocks, then by moving entire files.* Coming up with a working algorithm for achieving this took some thought, but once I had the outline of what I wanted to, putting the pieces together wasn't too bad, especially with the help of Gleam's static types to keep all the list operations straight. I probably should've done this with an array instead, but working with lists is more straightforward even if they're slower.

10. [Hoof It](https://adventofcode.com/2024/day/10) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_10.gleam), [Racket](/racket/aoc2024/day-10.rkt)) ⭐⭐ ♥️♥️♥️

     *Rate hiking trails in various ways.* I think I've finally done depth-first searches in AoC enough that I know how to do them right off the bat instead of having to fumble around online trying to translate pseudocode.  Another pretty standard "find something interesting about a grid of numbers" problem.

11. [Plutonian Pebbles](https://adventofcode.com/2024/day/11) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_11.gleam), [Racket](/racket/aoc2024/day-11.rkt)) ⭐ ♥️

     *Rocks split.* The standard "you can directly count part 1 but you can't count part 2" question that appears this time each year.

12. [Garden Groups](https://adventofcode.com/2024/day/12) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_12.gleam), [Racket](/racket/aoc2024/day-12.rkt)) ⭐⭐⭐ ♥️♥️♥️♥️♥️

     *Find the geometric properties of farm plots.* This one was a neat combination of a few subproblems -- identifying and tagging irregular areas in a grid, then figuring out their perimeters and number of sides.  I got a little stuck on writing the flood fill, but once I figured that out it all clicked.

13. [Claw Contraption](https://adventofcode.com/2024/day/13) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_13.gleam), [Racket](/racket/aoc2024/day-13.rkt)) ⭐⭐ ♥️♥️

     *How much does it cost to win the prize in every claw machine?* This looked like a complicated optimization problem at the start, but it ends up just being a lot of independent systems of linear equations, each with one solution.

14. [Restroom Redoubt](https://adventofcode.com/2024/day/14) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_14.gleam), [Racket](/racket/aoc2024/day-14.rkt)) ⭐⭐ ♥️♥️♥️♥️

     *Robots do Christmas choreography.* Part 2 for this one was really divisive online.  The problem statement's fairly open-ended, so it requires some guessing at what heuristics could tease out the solution.  After poking at the output for a while, I went with "find times when all the robots alone at their coordinates" and that got it in the first shot.

15. [Warehouse Woes](https://adventofcode.com/2024/day/15) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_15.gleam)) ⭐⭐⭐ ♥️♥️♥️

     *A robot pushes 1 $\times$ 2 boxes.* It's weird Sokoban!  Figuring out how to push overlapping boxes took a little bit of finagling.  I kept leaving chunks of moved boxes on the map, and accidentally duplicated the robot somehow once.

16. [Reindeer Maze](https://adventofcode.com/2024/day/16) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_16.gleam)) ⭐⭐⭐⭐ ♥️♥️♥️

     *Where should people sit to watch a reindeer race?* I'm getting more comfortable with search algorithms.  My end solution is a little hacky since I didn't account in my method for a final turn that some of the optimal paths need to make, but this is the point in the year where I start worrying less about elegance and just concentrate on getting a solution.

17. [Chronospatial Computer](https://adventofcode.com/2024/day/17) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_17.gleam), [Racket](/racket/aoc2024/day-17.rkt)) ⭐⭐⭐⭐ ♥️♥️♥️

     *Make a octal computer produce a [quine](https://en.wikipedia.org/wiki/Quine_(computing)).* Part 1 is a "read the instructions" problem, and then Part 2 stubbornly resists any kind of naive search.  I didn't make much progress with it until I got a hint about how each octal digit of the initial register corresponds to one byte in the output, and wrote a DFS to build up the register value from there.

18. [RAM Run](https://adventofcode.com/2024/day/18) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_18.gleam), [Racket](/racket/aoc2024/day-18.rkt)) ⭐ ♥️♥️

      *Avoid falling bytes until you can't any more.* There is probably a more optimal way of solving part 2 but a brute-force search adding each byte in sequence to the map was fast enough for me.  This was a weirdly underwhelming part 2; I expected the historians would have to move as the bytes fell instead of waiting until they'd all fallen.

19. [Linen Layout](https://adventofcode.com/2024/day/19) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_19.gleam), [Racket](/racket/aoc2024/day-19.rkt)) ⭐ ♥️♥️♥️

      *Make aesthetically-appealing towel arrangements.* I remember seeing an equivalent problem to this in a "intro to dynamic programming" video I watched last year.  The two parts have an almost-identical solution based on the same memoized search function.

20. [Race Condition](https://adventofcode.com/2024/day/20) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_20.gleam), [Racket](/racket/aoc2024/day-20.rkt)) ⭐⭐ ♥️♥️

      *Cheat as much as you can in a race.* Looks like it's going to be a grid search problem, but ends up just being a fairly straightforward fold over a set of points.  I got stuck on Part 2 for a bit because I thought cheating could only move you through walls; the actual mechanism's a lot more permissive.

21. [Keypad Conundrum](https://adventofcode.com/2024/day/21) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_21.gleam), [Racket](/racket/aoc2024/day-21.rkt)) ⭐⭐⭐⭐⭐ ♥️♥️♥️

      *Tell a robot to tell a robot to tell a robot to ... to tell a robot to enter a passcode.* The first one this year where I had to look at other people's solutions, the latest that's happened for me during AoC.  I was stuck trying to figure out a working method to make optimal robot arm motion paths, but once I had that, it was a pretty straightforward recursive search.

22. [Monkey Market](https://adventofcode.com/2024/day/22) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_22.gleam), [Racket](/racket/aoc2024/day-22.rkt)) ⭐ ♥️♥️♥️

      *Deputize a monkey to buy you as many bananas as possible by selling hiding spots at the best time.* Another problem that looks like it'll be an optimization problem with an exploding search space, but just making a bunch of dicts/hashmaps and folding them into each other produces the result in a couple seconds.

23. [LAN Party](https://adventofcode.com/2024/day/23) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_23.gleam), [Racket](/racket/aoc2024/day-23.rkt)) ⭐⭐⭐ ♥️

      *Find the biggest clique in a network.* One of those graph problems that's trivial if you're using a language like Python with a library like `networkx`, but I did not have that luxury.  I don't really know much graph theory so I'm surprised I managed to make this one work.

24. [Crossed Wires](https://adventofcode.com/2024/day/24) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_24.gleam)) ⭐⭐⭐⭐⭐ ♥️♥️♥️

      *Rewire an adder.* Part 1 has a neat, recursive answer that didn't take much work, which really made me fear for part 2 (and my fear was justified).  I didn't know enough about logic circuits to be able to make any sense of the graphical output or have a reasonable starting point for the part 2 solution, so I decided to port someone else's [imperative Javascript solution](https://github.com/piman51277/AdventOfCode/blob/master/solutions/2024/24/index2prog.js).  I think it's good practice to rewrite loops and mutation in a functional style, and after porting it I'm confident I understand what the solution is actually achieving beyond the code.

25. [Code Chronicle](https://adventofcode.com/2024/day/25) ([Gleam](/gleam/aoc2024/src/aoc_2024/day_25.gleam)) ⭐ ♥️♥️♥️

      *Match keys to locks.* The traditional light capstone problem for the 25th.  Nothing too complex, just a bunch of list manipulation.
