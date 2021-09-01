defmodule YamlE do
@moduledoc """
    Библиотека разбора и загрузки yaml файлов в переменные окружения.
    Использует FastYaml
    Преобразует всё в мапы и работает с ними.
  Вызов:
    YamlE.parse( map, options )
    YAMLE.parse_file( filename, options )

  Опции:
    keys_as_atom: true
    decode_values: true
    unwrap_keys: true

  Порядок работы:
  1. Сделать подстановки <<
  2. Преобразовать ключи в атомы
  3. Разобрать разбираемые значения - :атомы и числа
  4. с параметром unwrap_keys развернуть ключи вида [key1, key2, key3]=>value
     в список %{ key1 => value, key2 => value } и слить с исходным,
     удалив оригинал

  костыль: все подстановки должны быть в списке в одном ключе
  <<: [ *Subst1, *Subst2 ]
"""

  def into_env( fname, options \\ [] ) do
    parse_file(fname,parse_options( options ))
    |> Enum.map(
          fn{k0,v0}->{
                      k0,
                      Enum.map(
                        v0,
                        fn{k1,v1}->{k1,v1}end
                      )
                     }
          end)
    |> :application.set_env
  end

  def parse_file( fname, options \\ [] ) do
    parse(
      :fast_yaml.decode_from_file(fname, [:maps]),
      parse_options( options ) )
  end

  def parse( {:ok, [source|_]}, options ) when is_map(source) do
    parse( source, parse_options( options ) )
  end

  def parse( source, options ) when is_map(source) do
    cfg = parse_options( options )
    if Map.has_key?( source, "vars" ) do
      defaults = source["vars"]
      source |> Map.delete("vars") |> subst( defaults )
    else
      source
    end
    |> (fn(src)->if cfg.keys_as_atom, do: symbolize(src), else: src end).()
    |> (fn(src)->if cfg.unwrap_keys, do: unwrap_keys(src), else: src end).()
  end

  def parse({:ok, source}, _options), do: source

  def subst( %{ "<<" => list } = branch, defaults ) when is_list(list) do
    list
    |> List.foldl( branch, fn(i, map) -> Map.merge( map, defaults[i] ) end )
    |> Map.delete("<<")
  end
  def subst( %{ "<<" => value } = branch, defaults ) do
    branch
    |> Map.merge( defaults[ value ] )
    |> Map.delete("<<")
  end
  def subst( branch, defaults ) when is_map( branch ) do
    branch
    |> Enum.map( fn({ key, value }) -> { key, subst(value, defaults) } end )
    |> :lists.flatten
    |> Map.new
  end
  def subst( branch, _defaults ), do: branch

  def symbolize( branch ) do
    Enum.map( branch,
      fn
        { key, val } when val in ["true", "false", "nil"] ->
           { to_atom_maybe(key), String.to_existing_atom(val) }
        { key, val } when is_binary(val) ->
           {
             to_atom_maybe(key),
             cond do
               String.match?(val, ~r/^:\w[[:print:]]+$/) ->
                  (  String.trim_leading(val, ":") |> String.to_atom )
               String.match?(val, ~r/^\d+$/) ->
                  String.to_integer(val)
               true -> val
             end
           }
        { key, val } when is_map(val) ->
            { to_atom_maybe(key), symbolize(val) }
        { key, val } ->
            { to_atom_maybe(key), val }
       end)
     |> Map.new
  end

  def to_atom_maybe(i) when is_binary(i),do: String.to_atom(i)
  #def to_atom_maybe(i) when is_list(i),do: Enum.map(i, &to_atom_maybe/1)
  def to_atom_maybe(i),do: i
  def to_list_maybe(i) when is_list(i), do: i
  def to_list_maybe(i), do: [i]

  def unwrap_keys(m)when is_map(m) do
    :maps.fold(&unwrap_keys/3,%{},m)
  end
  def unwrap_keys(k,v,a)when is_list(k) do
    :lists.foldl(
      fn(i, a)-> Map.merge(a, %{i => v}) end,
      a, k )
  end
  def unwrap_keys(k,v,a)when is_map(v) do
    Map.merge(a,%{ k => unwrap_keys(v) })
  end
  def unwrap_keys(k,v,a), do: Map.merge(a,%{ k => v })

  def parse_options( opts ) when is_list(opts) or is_map(opts) do
    defaults = %{ keys_as_atom: true, decode_values: true, unwrap_keys: true }
    Map.merge(defaults, Map.new( opts ))
  end

end
