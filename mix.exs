defmodule YamlE.MixProject do
  use Mix.Project

  def project do
    [
      app: :yaml_e,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: false,
      deps: [{:fast_yaml, ">= 1.0.31"}]]
  end
  def application, do: [applications: [:logger,:fast_yaml]]

end
