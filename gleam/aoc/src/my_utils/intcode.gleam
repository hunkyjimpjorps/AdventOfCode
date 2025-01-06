import gary.{type ErlangArray}
import gary/array
import gleam/bool
import gleam/list
import my_utils/to

pub type Computer {
  Computer(intcode: ErlangArray(Int), pointer: Int, inputs: List(Int), outputs: List(Int))
}

type Op {
  Add
  Multiply
  Input
  Output
  JumpIfTrue
  JumpIfFalse
  LessThan
  Equals
  Halt
}

fn read_instruction(code: Int) {
  let modes = code / 100
  case code % 100 {
    1 -> Instruction(Add, get_parameter_modes(modes, 3))
    2 -> Instruction(Multiply, get_parameter_modes(modes, 3))
    3 -> Instruction(Input, get_parameter_modes(modes, 1))
    4 -> Instruction(Output, get_parameter_modes(modes, 1))
    5 -> Instruction(JumpIfTrue, get_parameter_modes(modes, 2))
    6 -> Instruction(JumpIfFalse, get_parameter_modes(modes, 2))
    7 -> Instruction(LessThan, get_parameter_modes(modes, 3))
    8 -> Instruction(Equals, get_parameter_modes(modes, 3))
    99 -> Instruction(Halt, [])
    _ -> panic as "unknown opcode"
  }
}

pub type ParameterMode {
  PositionMode
  ImmediateMode
}

type Instruction {
  Instruction(op: Op, params: List(ParameterMode))
}

fn assert_get(array, index) {
  let assert Ok(value) = array.get(array, index)
  value
}

fn assert_set(array, index, value) {
  let assert Ok(array) = array.set(array, index, value)
  array
}

pub fn parse_intcode(input: String) -> ErlangArray(Int) {
  input
  |> to.ints(",")
  |> array.from_list(default: -1)
  |> array.make_fixed()
}

pub fn run_intcode(computer: Computer, starting_at pointer: Int) {
  let Instruction(op:, params:) =
    computer.intcode |> assert_get(pointer) |> read_instruction

  use <- bool.guard(op == Halt, computer)
  list.index_map(params, fn(mode, i) {
    #(mode, assert_get(computer.intcode, pointer + i + 1))
  })
  |> do_op(op, _, computer)
  |> run_intcode(pointer + list.length(params) + 1)
}

fn get_parameter_modes(params: Int, params_count: Int) {
  do_get_parameter_modes(params, params_count, [])
}

fn do_get_parameter_modes(
  params: Int,
  params_count: Int,
  acc: List(ParameterMode),
) {
  case params_count {
    0 -> list.reverse(acc)
    n ->
      case params % 10 {
        0 -> PositionMode
        1 -> ImmediateMode
        _ -> panic as "not yet implemented"
      }
      |> list.prepend(acc, _)
      |> do_get_parameter_modes(params / 10, n - 1, _)
  }
}

fn do_op(op, parameters, computer: Computer) {
  case op {
    Add -> {
      let assert [a, b, #(_, to)] = parameters
      let result = get(computer.intcode, a) + get(computer.intcode, b)
      Computer(..computer, intcode: assert_set(computer.intcode, to, result))
    }
    Multiply -> {
      let assert [a, b, #(_, to)] = parameters
      let result = get(computer.intcode, a) * get(computer.intcode, b)
      Computer(..computer, intcode: assert_set(computer.intcode, to, result))
    }
    Input -> {
      let assert [#(_, to)] = parameters
      let assert [in, ..rest] = computer.inputs
      Computer(
        ..computer,
        intcode: assert_set(computer.intcode, to, in),
        inputs: rest,
      )
    }
    Output -> {
      let assert [to] = parameters
      let result = get(computer.intcode, to)
      Computer(
        ..computer,
        intcode: assert_set(computer.intcode, to.1, result),
        outputs: [result, ..computer.outputs],
      )
    }
    JumpIfTrue -> {
      let assert [a, #(_, to)] = parameters

      let test = get(computer.intcode, a)
      Computer(..computer, intcode: assert_set(computer.intcode, to, result))
    }
    JumpIfFalse -> todo
    LessThan -> todo
    Equals -> todo
    Halt -> panic
  }
}

fn get(intcode, param) {
  case param {
    #(ImmediateMode, val) -> val
    #(PositionMode, pointer) -> assert_get(intcode, pointer)
  }
}

pub fn read_outputs(computer: Computer) {
  computer.outputs
}

pub fn read_position(computer: Computer, position: Int) {
  array.get(computer.intcode, position)
}
