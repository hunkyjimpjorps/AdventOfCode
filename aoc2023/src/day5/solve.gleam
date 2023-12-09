import adglent.{First, Second}
import gleam/io
import gleam/string
import gleam/result
import gleam/list.{Continue, Stop}
import gleam/int
import gleam/function

// Types -------------------------------------------------------------------------------------------

pub type Almanac {
  Almanac(seeds: List(Int), mappers: List(Mapper))
}

pub type MappingRange {
  MRange(start: Int, end: Int, offset: Int)
}

pub type SeedRange {
  SRange(start: Int, end: Int)
}

type Mapper =
  List(MappingRange)

// Parsing -----------------------------------------------------------------------------------------

fn parse_input(input: String) {
  let assert ["seeds: " <> raw_seeds, ..raw_mappers] =
    string.split(input, on: "\n\n")

  let seeds = string_to_int_list(raw_seeds)
  let mappers =
    list.map(
      raw_mappers,
      function.compose(string.split(_, on: "\n"), parse_mapper),
    )
  Almanac(seeds, mappers)
}

fn string_to_int_list(str: String) {
  str
  |> string.split(on: " ")
  |> list.map(int.parse)
  |> result.values
}

fn parse_mapper(strs: List(String)) -> Mapper {
  let assert [_, ..raw_ranges] = strs
  list.map(raw_ranges, parse_mrange)
  |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
}

fn parse_mrange(str: String) -> MappingRange {
  let assert [destination, source, range_width] = string_to_int_list(str)
  MRange(source, source + range_width - 1, destination - source)
}

// Part 1 ------------------------------------------------------------------------------------------

pub fn part1(input: String) {
  let Almanac(seeds, mappers) = parse_input(input)

  list.map(seeds, list.fold(over: mappers, from: _, with: correspond))
  |> list.reduce(int.min)
  |> result.unwrap(0)
  |> string.inspect
}

fn correspond(n: Int, mapper: Mapper) {
  use acc, mrange <- list.fold_until(over: mapper, from: n)
  case mrange.start <= acc && acc <= mrange.end {
    True -> Stop(acc + mrange.offset)
    False -> Continue(acc)
  }
}

// Part 2 ------------------------------------------------------------------------------------------

pub fn part2(input: String) {
  let Almanac(seeds, mappers) = parse_input(input)

  let assert [SRange(answer, _), ..] =
    seeds
    |> list.sized_chunk(into: 2)
    |> list.map(fn(chunk) {
      let assert [start, length] = chunk
      [SRange(start, start + length - 1)]
      |> remap_all_seed_ranges(mappers)
    })
    |> list.flatten()
    |> list.sort(fn(a, b) { int.compare(a.start, b.start) })

  string.inspect(answer)
}

fn remap_all_seed_ranges(srs: List(SeedRange), mappers: List(Mapper)) {
  case mappers {
    [] -> srs
    [mapper, ..rest] ->
      list.flat_map(srs, remap_range(_, mapper))
      |> remap_all_seed_ranges(rest)
  }
}

fn remap_range(r: SeedRange, mapper: Mapper) -> List(SeedRange) {
  do_remap_range(r, mapper, [])
}

fn transform_range(r: SeedRange, mapper: MappingRange) -> SeedRange {
  SRange(r.start + mapper.offset, r.end + mapper.offset)
}

fn do_remap_range(r: SeedRange, mapper: Mapper, acc: List(SeedRange)) {
  case mapper {
    // no more mappings -> no mapping covers this range
    [] -> [r, ..acc]
    // range is to the left of current mapping -> no mapping covers this range
    [m, ..] if r.end < m.start -> [r, ..acc]
    // range is to the right of current mapping -> move to next mapping
    [m, ..ms] if r.start > m.end -> do_remap_range(r, ms, acc)
    // range is fully inside mapping -> range is transformed
    [m, ..] if r.start >= m.start && r.end <= m.end -> [
      transform_range(r, m),
      ..acc
    ]
    // range overlaps start but not end -> left side not transformed, right side transformed
    [m, ..] if r.start < m.start && r.end <= m.end -> [
      SRange(r.start, m.start - 1),
      transform_range(SRange(m.start, r.end), m),
      ..acc
    ]
    // range overlaps end but not start -> left side transformed, right side moves to next mapping
    [m, ..ms] if r.start >= m.start && r.end > m.end ->
      do_remap_range(SRange(m.end + 1, r.end), ms, [
        transform_range(SRange(r.start, m.end), m),
        ..acc
      ])
    // mapping is fully inside range -> left not transformed, middle transformed, right to next
    [m, ..ms] ->
      do_remap_range(SRange(m.end + 1, r.end), ms, [
        SRange(r.start, m.start - 1),
        transform_range(SRange(m.start, m.end), m),
        ..acc
      ])
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("5")
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
