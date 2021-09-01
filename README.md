# YamlE

Библиотека разбора и загрузки yaml файлов в переменные окружения.

    * Использует FastYaml
    * Преобразует всё в мапы и работает с ними.

  Вызов:

    YamlE.parse( map, options )
    YAMLE.parse_file( filename, options )

  Опции:

    keys_as_atom: true
    decode_values: true
    unwrap_keys: true

##  Порядок работы:

  1. Сделать подстановки <<
  2. Преобразовать ключи в атомы
  3. Разобрать разбираемые значения - :атомы и числа
  4. с параметром unwrap_keys развернуть ключи вида [key1, key2, key3]=>value
     в список %{ key1 => value, key2 => value } и слить с исходным,
     удалив оригинал

  **костыль: все подстановки должны быть в списке в одном ключе**

        <<: [ *Subst1, *Subst2 ]

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `yaml_e` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yaml_e, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/yaml_e](https://hexdocs.pm/yaml_e).
