import gary.{type ErlangArray}
import gary/array
import gleam/bool
import gleam/list
import gleam/string
import my_utils/to

// TYPES -------------------------------------------------------------------------------------------

pub type Computer {
  Computer(
    intcode: ErlangArray(Int),
    pointer: Int,
    inputs: List(Int),
    outputs: List(Int),
  )
}

pub type ParameterMode {
  PositionMode
  ImmediateMode
}

type Instruction {
  Instruction(op: fn(Computer, Params) -> Computer, params: Int, modes: Int)
  Halt
}

type Params =
  List(#(ParameterMode, Int))

// UTILITY FUNCTIONS -------------------------------------------------------------------------------

fn assert_get(array: ErlangArray(a), index: Int) -> a {
  let assert Ok(value) = array.get(array, index)
  value
}

fn assert_set(array: ErlangArray(b), index: Int, value: b) -> ErlangArray(b) {
  let assert Ok(array) = array.set(array, index, value)
  array
}

// INITIALIZATION ----------------------------------------------------------------------------------

pub fn parse_intcode(input: String) -> ErlangArray(Int) {
  input
  |> to.ints(",")
  |> array.from_list(default: -1)
  |> array.make_fixed()
}

pub fn initialize_computer(intcode: ErlangArray(Int)) -> Computer {
  Computer(intcode:, outputs: [], inputs: [], pointer: 0)
}

// RUNNING THE COMPUTER ----------------------------------------------------------------------------

pub fn run_intcode(computer: Computer) -> Computer {
  case next_instruction(computer) {
    Halt -> computer
    Instruction(..) as op ->
      computer
      |> do_op(op)
      |> run_intcode()
  }
}

fn next_instruction(computer: Computer) -> Instruction {
  let code = computer |> read_at_pointer
  let modes = code / 100
  case code % 100 {
    1 -> Instruction(add, 3, modes)
    2 -> Instruction(multiply, 3, modes)
    3 -> Instruction(input, 1, modes)
    4 -> Instruction(output, 1, modes)
    5 -> Instruction(jump_if_true, 2, modes)
    6 -> Instruction(jump_if_false, 2, modes)
    7 -> Instruction(is_less_than, 3, modes)
    8 -> Instruction(is_equal, 3, modes)
    99 -> Halt
    _ -> panic as { "unknown opcode" <> string.inspect(code) }
  }
}

fn do_op(computer: Computer, op: Instruction) -> Computer {
  let assert Instruction(op, param_count, params) = op
  let Computer(pointer:, ..) = computer

  let vals =
    list.range(pointer + 1, pointer + param_count)
    |> list.map(read_position(computer, _))
  let modes = get_parameter_modes(params, param_count)
  let parameters = list.zip(modes, vals)

  op(computer, parameters)
}

fn get_parameter_modes(params: Int, params_count: Int) {
  do_get_parameter_modes(params, params_count, [])
}

fn do_get_parameter_modes(
  params: Int,
  params_count: Int,
  acc: List(ParameterMode),
) {
  use <- bool.guard(params_count == 0, list.reverse(acc))
  case params % 10 {
    0 -> PositionMode
    1 -> ImmediateMode
    _ -> panic as "not yet implemented"
  }
  |> list.prepend(acc, _)
  |> do_get_parameter_modes(params / 10, params_count - 1, _)
}

// OPERATIONS --------------------------------------------------------------------------------------

fn get(computer, param) {
  case param {
    #(ImmediateMode, val) -> val
    #(PositionMode, pointer) -> read_position(computer, pointer)
  }
}

fn add(computer: Computer, parameters: Params) -> Computer {
  let assert [a, b, to] = parameters
  computer
  |> set_location(to.1, get(computer, a) + get(computer, b))
  |> move_pointer(parameters)
}

fn multiply(computer: Computer, parameters: Params) -> Computer {
  let assert [a, b, to] = parameters
  computer
  |> set_location(to.1, get(computer, a) * get(computer, b))
  |> move_pointer(parameters)
}

fn input(computer: Computer, parameters: Params) -> Computer {
  let assert [to] = parameters
  let #(in, computer) = pop_input(computer)
  computer
  |> set_location(to.1, in)
  |> move_pointer(parameters)
}

fn output(computer: Computer, parameters: Params) -> Computer {
  let assert [to] = parameters
  let result = get(computer, to)
  computer
  |> push_output(result)
  |> move_pointer(parameters)
}

fn jump_if_true(computer: Computer, parameters: Params) -> Computer {
  let assert [a, to] = parameters
  case get(computer, a) {
    0 -> move_pointer(computer, parameters)
    _ -> jump_pointer(computer, get(computer, to))
  }
}

fn jump_if_false(computer: Computer, parameters: Params) -> Computer {
  let assert [a, to] = parameters
  case get(computer, a) {
    0 -> jump_pointer(computer, get(computer, to))
    _ -> move_pointer(computer, parameters)
  }
}

fn is_less_than(computer: Computer, parameters: Params) -> Computer {
  let assert [a, b, to] = parameters
  case get(computer, a) < get(computer, b) {
    True -> 1
    False -> 0
  }
  |> set_location(computer, to.1, _)
  |> move_pointer(parameters)
}

fn is_equal(computer: Computer, parameters: Params) -> Computer {
  let assert [a, b, to] = parameters
  case get(computer, a) == get(computer, b) {
    True -> 1
    False -> 0
  }
  |> set_location(computer, to.1, _)
  |> move_pointer(parameters)
}

// STATE MANIPULATION ------------------------------------------------------------------------------

pub fn set_location(computer, location, value) {
  Computer(..computer, intcode: assert_set(computer.intcode, location, value))
}

pub fn push_input(computer: Computer, input) {
  Computer(..computer, inputs: [input, ..computer.inputs])
}

pub fn set_inputs(computer: Computer, inputs) {
  Computer(..computer, inputs: inputs)
}

fn pop_input(computer: Computer) {
  let assert [first, ..rest] = computer.inputs
  #(first, Computer(..computer, inputs: rest))
}

fn push_output(computer: Computer, out) {
  Computer(..computer, outputs: [out, ..computer.outputs])
}

fn jump_pointer(computer, pointer) {
  Computer(..computer, pointer: pointer)
}

fn move_pointer(computer, params) {
  Computer(..computer, pointer: computer.pointer + list.length(params) + 1)
}

// OUTPUT ------------------------------------------------------------------------------------------

pub fn read_at_pointer(computer: Computer) {
  read_position(computer, computer.pointer)
}

pub fn read_outputs(computer: Computer) {
  computer.outputs
}

pub fn pop_output(computer: Computer) {
  let assert [first, ..rest] = computer.outputs
  #(first, Computer(..computer, outputs: rest))
}

pub fn read_position(computer: Computer, position: Int) {
  assert_get(computer.intcode, position)
}
