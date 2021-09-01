defmodule YamlE.Config do
  @behaviour Config.Provider
  import YamlE

  def init(path) when is_binary(path), do: path
  def load(config, path) do
    {:ok, _pid} = Application.ensure_all_started(:fast_yaml)
    Config.Reader.merge( config, YamlE.parse_file(path) )
  end
end
