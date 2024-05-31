//adapted from https://github.com/byronanderson/adventofcode2021/blob/main/gleam_advent/src/priority_queue.gleam

import gleam/dict.{type Dict}

type Ref

@external(erlang, "erlang", "make_ref")
fn make_ref() -> Ref

type PQueue(a)

pub opaque type PriorityQueue(a) {
  PriorityQueue(queue: PQueue(#(a, Ref)), refs: Dict(a, Ref))
}

type OutResult(a) {
  Empty
  Value(a, Int)
}

@external(erlang, "pqueue2", "new")
fn new_() -> PQueue(a)

@external(erlang, "pqueue2", "in")
fn insert_(item: a, prio: Int, queue: PQueue(a)) -> PQueue(a)

@external(erlang, "pqueue2", "pout")
fn pop_(queue: PQueue(a)) -> #(OutResult(a), PQueue(a))

pub fn new() -> PriorityQueue(a) {
  PriorityQueue(queue: new_(), refs: dict.new())
}

pub fn insert(
  queue: PriorityQueue(a),
  value: a,
  priority: Int,
) -> PriorityQueue(a) {
  let ref = make_ref()

  let refs =
    queue.refs
    |> dict.insert(value, ref)

  PriorityQueue(
    refs: refs,
    queue: insert_(#(value, ref), priority, queue.queue),
  )
}

pub fn pop(queue: PriorityQueue(a)) -> Result(#(a, PriorityQueue(a)), Nil) {
  case pop_(queue.queue) {
    #(Value(#(value, ref), _priority), pqueue) -> {
      let assert Ok(recently_enqueued_ref) = dict.get(queue.refs, value)
      case recently_enqueued_ref == ref {
        True -> Ok(#(value, PriorityQueue(refs: queue.refs, queue: pqueue)))
        False -> pop(PriorityQueue(refs: queue.refs, queue: pqueue))
      }
    }
    #(Empty, _pqueue) -> {
      Error(Nil)
    }
  }
}
