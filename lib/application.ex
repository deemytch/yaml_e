defmodule YamlE.Application do
  @moduledoc "Библиотека загрузки yaml файлов прямо в переменные окружения"
  use Application
  @impl true
  def start(_type, _args), do: {:ok,[]}
end
