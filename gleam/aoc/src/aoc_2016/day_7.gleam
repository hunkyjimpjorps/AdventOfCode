import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import my_utils/to

type Input =
  List(IP)

pub type IP {
  IP(addresses: List(String), hypernets: List(String))
}

pub fn parse_ip(ip) {
  let assert Ok(re) = regexp.from_string("\\[(.*?)\\]")
  let hypernets =
    regexp.scan(with: re, content: ip)
    |> list.flat_map(fn(match) { match.submatches })
    |> option.values

  let assert Ok(re) = regexp.from_string("\\[.*?\\]")
  let addresses = regexp.split(with: re, content: ip)

  IP(addresses:, hypernets:)
}

pub fn parse(input: String) -> Input {
  to.delimited_list(input, "\n", parse_ip)
}

fn is_abba(str: String) {
  string.length(str) == 4
  && str == string.reverse(str)
  && string.slice(str, 0, 1) != string.slice(str, 1, 1)
}

fn contains_abba(str: String) {
  case string.is_empty(str) {
    True -> False
    False ->
      is_abba(string.slice(str, 0, 4))
      || contains_abba(string.drop_start(str, 1))
  }
}

pub fn pt_1(input: Input) {
  list.count(input, fn(ip) {
    list.any(ip.addresses, contains_abba)
    && !list.any(ip.hypernets, contains_abba)
  })
}

fn is_aba(str: String) {
  string.length(str) == 3
  && str == string.reverse(str)
  && string.slice(str, 0, 1) != string.slice(str, 1, 1)
}

fn find_abas(str: String, acc: List(String)) {
  case string.is_empty(str) {
    True -> acc
    False -> {
      let aba = string.slice(str, 0, 3)
      case is_aba(aba) {
        True -> [make_bab(aba), ..acc]
        False -> acc
      }
      |> find_abas(string.drop_start(str, 1), _)
    }
  }
}

fn make_bab(aba: String) {
  let a = string.slice(aba, 0, 1)
  let b = string.slice(aba, 1, 1)

  b <> a <> b
}

pub fn pt_2(input: Input) {
  list.count(input, fn(ip) {
    let babs = list.flat_map(ip.addresses, find_abas(_, []))

    list.any(ip.hypernets, fn(hypernet) {
      list.any(babs, string.contains(does: hypernet, contain: _))
    })
  })
}
