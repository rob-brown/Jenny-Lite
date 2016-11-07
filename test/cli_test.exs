defmodule JennyLite.CLI.Test do
  use ExUnit.Case, async: true
  doctest JennyLite.CLI

  alias JennyLite.CLI

  test "parse empty args" do
    assert :no_files == CLI.parse_args []
  end

  test "parse help switch" do
    assert parse("--help") == :help
    assert parse("--help --file file") == :help
    assert parse("-h") == :help
    assert parse("help") == :help
  end

  test "parse one file switch" do
    assert parse("--file file1") == %{file: ["file1"], ignore: []}
    assert parse("-- file1") == %{file: ["file1"], ignore: []}
  end

  test "parse many files switches" do
    assert parse("--file file1 --file file2") == %{file: ["file2", "file1"], ignore: []}
  end

  test "parse file with -- prefix" do
    assert parse("--file file1 --file file2 -- --file3") == %{file: ["file2", "file1", "--file3"], ignore: []}
  end

  test "parse no files" do
    assert parse("--ignore file1") == :no_files
  end

  test "parse file and ignore" do
    assert parse("--file file1 --ignore file2") == %{file: ["file1"], ignore: ["file2"]}
  end

  defp parse(arg_string) do
    arg_string
    |> String.split(" ")
    |> Enum.reject(& &1 == "")
    |> CLI.parse_args
  end
end
