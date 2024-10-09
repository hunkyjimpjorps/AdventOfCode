import gleam/erlang/process.{type Subject, Normal}
import gleam/option.{None}
import gleam/otp/actor.{type Next, Continue, Stop}
import gleam/set.{type Set}

const timeout = 1000

pub type Message(k) {
  Shutdown
  Check(key: k, client: Subject(Bool))
  Add(key: k)
  Drop(key: k)
  Pop(client: Subject(Result(k, Nil)))
}

fn handle_message(message: Message(k), set: Set(k)) -> Next(Message(k), Set(k)) {
  case message {
    Shutdown -> Stop(Normal)
    Check(key, client) -> {
      process.send(client, set.contains(set, key))
      Continue(set, None)
    }
    Add(key) -> Continue(set.insert(set, key), None)
    Drop(key) -> Continue(set.delete(set, key), None)
    Pop(client) -> {
      case set.to_list(set) {
        [next, ..] -> {
          process.send(client, Ok(next))
          Continue(set.delete(set, next), None)
        }
        [] -> {
          process.send(client, Error(Nil))
          Stop(Normal)
        }
      }
    }
  }
}

pub fn start_actor(with: Set(a)) {
  let assert Ok(actor) = actor.start(with, handle_message)
  actor
}

pub fn pop(actor) {
  process.call(actor, Pop, timeout)
}

pub fn check(actor, value) {
  process.call(actor, Check(value, _), timeout)
}

pub fn drop(actor, value) {
  process.send(actor, Drop(value))
}
