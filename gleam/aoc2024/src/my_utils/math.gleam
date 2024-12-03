pub fn pow(base: Int, exponent: Int) {
  case exponent {
    0 -> 1
    1 -> base
    n if n % 2 == 0 -> pow(base * base, n / 2)
    n -> base * pow(base, n - 1)
  }
}
