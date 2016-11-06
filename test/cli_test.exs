defmodule JennyLite.CLI.Test do
  use ExUnit.Case
  doctest JennyLite.CLI

  alias JennyLite.CLI

  test "parse args" do
    parse = (& &1 |> String.split(" ") |> Enum.reject(fn x -> x == "" end) |> CLI.parse_args)
    assert :no_files == CLI.parse_args []
    assert parse.("--help") == :help
    assert parse.("--help --file file") == :help
    assert parse.("-h") == :help
    assert parse.("help") == :help
    assert parse.("--file file1") == %{file: ["file1"], ignore: []}
    assert parse.("--file file1 --file file2") == %{file: ["file2", "file1"], ignore: []}
    assert parse.("--file file1 --file file2 -- --file3") == %{file: ["file2", "file1", "--file3"], ignore: []}
    assert parse.("-- file1") == %{file: ["file1"], ignore: []}
    assert parse.("--ignore file1") == :no_files
    assert parse.("--file file1 --ignore file2") == %{file: ["file1"], ignore: ["file2"]}
  end
end
