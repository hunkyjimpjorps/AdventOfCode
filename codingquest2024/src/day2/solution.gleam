import gleam/bit_array
import gleam/list
import gleam/int
import gleam/io
import gleam/string
import simplifile

pub type Location {
  Internal
  Passenger
  Other
}

pub type Packet {
  Packet(length: Int, endpoint: Location)
}

pub fn main() {
  let assert Ok(data) = simplifile.read(from: "./src/day2/data.txt")

  let #(internal_packets, passenger_packets) =
    data
    |> string.split("\n")
    |> list.map(parse_packet)
    |> list.partition(fn(p) { p.endpoint == Internal })

  {
    int.to_string(sum_packet_lengths(internal_packets))
    <> "/"
    <> int.to_string(sum_packet_lengths(passenger_packets))
  }
  |> io.println()
}

fn parse_packet(raw_packet: String) {
  let assert Ok(<<
    _:bytes-size(2),
    length:int-size(16),
    _:bytes-size(8),
    source:bytes-size(4),
    destination:bytes-size(4),
  >>) = bit_array.base16_decode(raw_packet)

  Packet(length, set_endpoint(source, destination))
}

fn set_endpoint(source: BitArray, dest: BitArray) -> Location {
  case identify_location(source), identify_location(dest) {
    Other, Internal | Internal, Other -> Internal
    Other, Passenger | Passenger, Other -> Passenger
    _, _ -> Other
  }
}

fn identify_location(ip: BitArray) -> Location {
  case ip {
    <<192, 168, _, _>> -> Internal
    <<10, 0, _, _>> -> Passenger
    _ -> Other
  }
}

fn sum_packet_lengths(packets: List(Packet)) -> Int {
  use acc, p <- list.fold(packets, 0)
  acc + p.length
}
