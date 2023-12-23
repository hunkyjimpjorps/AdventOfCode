import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regex
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Point {
  Point(x: Int, y: Int, z: Int)
}

fn down_one(p: Point) -> Point {
  Point(..p, z: p.z - 1)
}

type Block {
  Block(index: Int, from: Point, to: Point)
}

fn compare_blocks(b1: Block, b2: Block) {
  int.compare(b1.to.z, b2.to.z)
}

type Space =
  Dict(Point, Block)

type AllBlocks =
  Dict(Block, List(Point))

type BlockTree =
  Dict(Int, Set(Int))

fn parse_block(index: Int, input: String) -> Block {
  let assert Ok(re) = regex.from_string("(.*),(.*),(.*)~(.*),(.*),(.*)")

  let assert [scan] = regex.scan(with: re, content: input)

  let assert [x1, y1, z1, x2, y2, z2] =
    scan.submatches
    |> option.all
    |> option.unwrap([])
    |> list.map(int.parse)
    |> result.values
  Block(index: index, from: Point(x1, y1, z1), to: Point(x2, y2, z2))
}

fn cross_section_at_level(b: Block, z: Int) -> List(Point) {
  use x <- list.flat_map(list.range(b.from.x, b.to.x))
  use y <- list.map(list.range(b.from.y, b.to.y))
  Point(x, y, z)
}

fn place_block(space: Space, b: Block, z: Int) -> Space {
  let now_occupied = {
    use x <- list.flat_map(list.range(b.from.x, b.to.x))
    use y <- list.flat_map(list.range(b.from.y, b.to.y))
    use z <- list.map(list.range(z, z + b.to.z - b.from.z))
    #(Point(x, y, z), b)
  }

  dict.merge(space, dict.from_list(now_occupied))
}

fn find_lowest_level(space: Space, b: Block) -> Space {
  do_find_lowest(space, b, b.from.z)
}

fn do_find_lowest(space: Space, b: Block, z: Int) -> Space {
  let is_intersecting =
    list.any(cross_section_at_level(b, z), dict.has_key(space, _))

  case z, is_intersecting {
    0, _ -> place_block(space, b, 1)
    _, True -> place_block(space, b, z + 1)
    _, False -> do_find_lowest(space, b, z - 1)
  }
}

fn to_block_positions(space: Space) -> AllBlocks {
  use acc, point, index <- dict.fold(space, dict.new())
  use points <- dict.update(acc, index)
  case points {
    Some(ps) -> [point, ..ps]
    None -> [point]
  }
}

fn above_blocks(blocks: AllBlocks) -> BlockTree {
  use acc, block, points <- dict.fold(blocks, dict.new())
  use _ <- dict.update(acc, block.index)
  {
    use above_block, above_points <- dict.filter(blocks)
    above_block.index != block.index
    && list.any(above_points, fn(p) { list.contains(points, down_one(p)) })
  }
  |> dict.keys
  |> list.map(fn(b) { b.index })
  |> set.from_list
}

fn below_blocks(blocktree: BlockTree) -> BlockTree {
  use acc, block, _ <- dict.fold(blocktree, dict.new())
  use _ <- dict.update(acc, block)
  {
    use _, aboves <- dict.filter(blocktree)
    set.contains(aboves, block)
  }
  |> dict.keys
  |> set.from_list
}

fn vulnerable_blocks(below_tree: BlockTree) -> List(Int) {
  use block <- list.filter(dict.keys(below_tree))
  use bs <- list.any(dict.values(below_tree))
  !{ set.size(bs) == 0 } && { set.size(set.delete(bs, block)) == 0 }
}

pub fn part1(input: String) {
  let settled_blocks =
    input
    |> string.split("\n")
    |> list.index_map(parse_block)
    |> list.sort(compare_blocks)
    |> list.fold(dict.new(), find_lowest_level)

  let block_positions = to_block_positions(settled_blocks)
  let above_blocks = above_blocks(block_positions)
  let below_blocks = below_blocks(above_blocks)

  let vulnerable_blocks = vulnerable_blocks(below_blocks)

  list.length(dict.keys(block_positions))
  - list.length(vulnerable_blocks)
  |> string.inspect
}

fn all_falling_blocks(n: Int, above: BlockTree, below: BlockTree) {
  let starting_set = set.insert(set.new(), n)
  do_falling_blocks(starting_set, starting_set, above, below)
}

fn do_falling_blocks(
  fallen: Set(Int),
  blocks: Set(Int),
  above: BlockTree,
  below: BlockTree,
) -> Int {
  use <- bool.guard(set.size(blocks) == 0, set.size(fallen) - 1)

  let blocks_above =
    {
      use block <- list.flat_map(set.to_list(blocks))
      let assert Ok(supports) = dict.get(above, block)
      use support <- list.filter(set.to_list(supports))
      let assert Ok(supportings) = dict.get(below, support)
      use supporting <- list.all(set.to_list(supportings))
      set.contains(fallen, supporting)
    }
    |> set.from_list()

  set.union(fallen, blocks_above)
  |> do_falling_blocks(blocks_above, above, below)
}

pub fn part2(input: String) {
  let settled_blocks =
    input
    |> string.split("\n")
    |> list.index_map(parse_block)
    |> list.sort(compare_blocks)
    |> list.fold(dict.new(), find_lowest_level)

  let block_positions = to_block_positions(settled_blocks)
  let above_blocks = above_blocks(block_positions)
  let below_blocks = below_blocks(above_blocks)

  let vulnerable_blocks = vulnerable_blocks(below_blocks)

  list.map(vulnerable_blocks, all_falling_blocks(_, above_blocks, below_blocks))
  |> int.sum
  |> string.inspect
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("22")
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
