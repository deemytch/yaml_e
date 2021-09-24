defmodule YamlETest do
  use ExUnit.Case
  doctest YamlE

  test "parse params" do
    assert YamlE.parse_options( unwrap_keys: false ) == %{ keys_as_atom: true, decode_values: true, unwrap_keys: false }
    assert YamlE.parse_options( %{ keys_as_atom: true, decode_values: false, unwrap_keys: false } ) == %{ keys_as_atom: true, decode_values: false, unwrap_keys: false }
  end

  test "parse string" do
    assert YamlE.parse(File.read!("test/amqp.yml")) == %{
        amqp: %{
          "ababa" => "Control.None",
          "galam" => "Control.None",
          "aga" => "Control.None",
          "search" => "Control.GET",
          "get" => "Control.GET",
          "publish" => "Control.POST",
          "delete" => "Control.POST",
          "account" => "Control.POST",
          conn: %{
            name: :int,
            port: 15671,
            login: "username"
          }
        },
        http: %{ defaults: true },
        db: %{
          username: "postgres",
          namespace: :app_id
        }}
  end

  test "parse file" do
    assert YamlE.parse_file( "test/amqp.yml" ) == %{
        amqp: %{
          "ababa" => "Control.None",
          "galam" => "Control.None",
          "aga" => "Control.None",
          "search" => "Control.GET",
          "get" => "Control.GET",
          "publish" => "Control.POST",
          "delete" => "Control.POST",
          "account" => "Control.POST",
          conn: %{
            name: :int,
            port: 15671,
            login: "username"
          }
        },
        http: %{ defaults: true },
        db: %{
          username: "postgres",
          namespace: :app_id
        }}
  end
  test "insert env" do
    YamlE.into_env("test/amqp.yml")
    assert {:ok, true } = Application.fetch_env(:http, :defaults)
  end
end
