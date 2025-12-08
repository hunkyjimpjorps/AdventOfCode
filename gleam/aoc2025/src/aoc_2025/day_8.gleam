import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleamy/priority_queue.{type Queue} as prioq
import my_utils/math
import my_utils/to

pub type XYZ {
  XYZ(x: Int, y: Int, z: Int)
}

pub type Room {
  Room(boxes: Dict(XYZ, Int), circuits: Dict(Int, Set(XYZ)), seen: Set(XYZ))
}

pub fn parse(input: String) -> List(XYZ) {
  use line <- to.delimited_list(input, "\n")
  let assert [x, y, z] = to.delimited_list(line, ",", to.int)
  XYZ(x:, y:, z:)
}

fn make_room(input) {
  Room(
    boxes: input
      |> list.index_map(fn(point, index) { #(point, index) })
      |> dict.from_list,
    circuits: input
      |> list.index_map(fn(point, index) { #(index, set.from_list([point])) })
      |> dict.from_list,
    seen: set.new(),
  )
}

pub fn pt_1(input: List(XYZ)) {
  input
  |> list.combination_pairs
  |> prioq.from_list(compare)
  |> get_next_best(make_room(input), 1000)
  |> list.map(set.size)
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> int.product
}

fn dist(p1: XYZ, p2: XYZ) -> Int {
  math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2) + math.pow(p1.z - p2.z, 2)
}

fn compare(pair1: #(XYZ, XYZ), pair2: #(XYZ, XYZ)) {
  int.compare(dist(pair1.0, pair1.1), dist(pair2.0, pair2.1))
}

fn get_next_best(
  prioq: Queue(#(XYZ, XYZ)),
  room: Room,
  remaining: Int,
) -> List(Set(XYZ)) {
  case remaining {
    0 -> room.circuits |> dict.values
    n -> {
      let assert Ok(#(points, rest)) = prioq.pop(prioq)
      let updated_room = unify(room, points)
      get_next_best(rest, updated_room, n - 1)
    }
  }
}

fn unify(room: Room, points: #(XYZ, XYZ)) -> Room {
  let #(point_a, point_b) = points
  case dict.get(room.boxes, point_a), dict.get(room.boxes, point_b) {
    Ok(circuit_a), Ok(circuit_b) if circuit_a == circuit_b -> room
    Ok(circuit_a), Ok(circuit_b) -> {
      let assert Ok(boxes_a) = dict.get(room.circuits, circuit_a)
      let assert Ok(boxes_b) = dict.get(room.circuits, circuit_b)
      Room(
        boxes: set.fold(boxes_b, room.boxes, fn(boxes, box) {
          dict.insert(boxes, box, circuit_a)
        }),
        circuits: room.circuits
          |> dict.delete(circuit_b)
          |> dict.insert(circuit_a, set.union(boxes_a, boxes_b)),
        seen: room.seen |> set.insert(point_a) |> set.insert(point_b),
      )
    }
    _, _ -> panic as "Junction box not found in room"
  }
}

pub fn pt_2(input: List(XYZ)) -> Int {
  input
  |> list.combination_pairs
  |> prioq.from_list(compare)
  |> find_circuit_closer(make_room(input))
}

fn find_circuit_closer(prioq: Queue(#(XYZ, XYZ)), room: Room) -> Int {
  let assert Ok(#(points, rest)) = prioq.pop(prioq)
  let updated_room = unify(room, points)
  case set.size(updated_room.seen) == 1000 {
    False -> find_circuit_closer(rest, updated_room)
    True -> {
      case dict.values(updated_room.circuits) {
        [_] -> { points.0 }.x * { points.1 }.x
        _ -> find_circuit_closer(rest, updated_room)
      }
    }
  }
}
