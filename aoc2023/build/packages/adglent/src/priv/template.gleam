import gleam/list
import gleam/string

pub fn render(
  template: String,
  substitutions: List(#(String, String)),
) -> String {
  substitutions
  |> list.fold(
    template,
    fn(template, substitution) {
      let #(name, value) = substitution
      template
      |> string.replace("{{ " <> name <> " }}", value)
    },
  )
  |> string.trim <> "\n"
}
