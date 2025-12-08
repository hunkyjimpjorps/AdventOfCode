import gleam/int
import gleam/list
import gleam/set
import gleamy/priority_queue as prioq
import my_utils/math
import my_utils/to

pub type XYZ {
  XYZ(x: Int, y: Int, z: Int)
}

pub fn parse(input: String) -> List(XYZ) {
  use line <- to.delimited_list(input, "\n")
  let assert [x, y, z] = to.delimited_list(line, ",", to.int)
  XYZ(x:, y:, z:)
}

pub fn pt_1(input: List(XYZ)) {
  input
  |> list.combination_pairs
  |> prioq.from_list(compare)
  |> get_next_best([], 1000)
  |> list.map(set.size)
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> int.product
}

fn dist(p1: XYZ, p2: XYZ) {
  math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2) + math.pow(p1.z - p2.z, 2)
}

fn compare(pair1: #(XYZ, XYZ), pair2: #(XYZ, XYZ)) {
  int.compare(dist(pair1.0, pair1.1), dist(pair2.0, pair2.1))
}

fn get_next_best(prioq, disjoint_sets, remaining) {
  case remaining {
    0 -> disjoint_sets
    n -> {
      let assert Ok(#(points, rest)) = prioq.pop(prioq)
      let updated_sets = classify(disjoint_sets, points)
      get_next_best(rest, updated_sets, n - 1)
    }
  }
}

fn classify(disjoint_sets, points: #(XYZ, XYZ)) {
  let #(has_first, doesnt_have_first) =
    list.partition(disjoint_sets, set.contains(_, points.0))
  let #(has_second, doesnt_have_second) =
    list.partition(disjoint_sets, set.contains(_, points.1))

  case has_first, has_second {
    [], [] -> [set.from_list([points.0, points.1]), ..disjoint_sets]
    [set], [] -> [set.insert(set, points.1), ..doesnt_have_first]
    [], [set] -> [set.insert(set, points.0), ..doesnt_have_second]
    [set1], [set2] -> [
      set.union(set1, set2),
      ..list.filter(disjoint_sets, fn(s) {
        !{ set.contains(s, points.0) || set.contains(s, points.1) }
      })
    ]
    _, _ -> panic
  }
}

pub fn pt_2(input: List(XYZ)) {
  input
  |> list.combination_pairs
  |> prioq.from_list(compare)
  |> find_circuit_closer(list.map(input, fn(p) { set.from_list([p]) }))
}

fn find_circuit_closer(prioq, disjoint_sets) {
  let assert Ok(#(points, rest)) = prioq.pop(prioq)
  let updated_sets = classify(disjoint_sets, points)
  case updated_sets {
    [_] -> { points.0 }.x * { points.1 }.x
    _ -> find_circuit_closer(rest, updated_sets)
  }
}
