defmodule JennyLite.CLI do
  alias JennyLite.CLI.Flag
  alias JennyLite.Expander

  def main(argv) do
    argv |> parse_args |> process
  end

  def parse_args(argv) do
    {options, argv, errors} = OptionParser.parse argv, strict: Flag.switches, aliases: Flag.aliases
    map_options = options_to_map options
    case {map_options, argv, errors} do
      {%{help: _}, _, _} ->
        :help
      {%{file: files, ignore: ignores}, others, []} ->
        %{file: files ++ others, ignore: ignores}
      {%{file: files}, others, []} ->
        %{file: files ++ others, ignore: []}
      {%{}, ["help"], []} ->
        :help
      {%{}, [], []} ->
        :no_files
      {%{}, files, []} ->
        %{file: files, ignore: []}
      {_, _, errors} ->
        {:invalid, errors}
    end
  end

  defp process(%{file: [], ignore: _}) do
    process :no_files
  end
  defp process(%{file: files, ignore: ignores}) do
    # TODO: Use a process pool.
    files
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.reject(& &1 in ignores)
    |> Enum.filter(&file_changed?/1)
    |> Enum.each(&Expander.expand_file/1)
    System.halt 0
  end
  defp process(:help) do
    print_help
    System.halt 0
  end
  defp process(:no_files) do
    IO.puts "No files listed to expand."
    process :help
  end
  defp process({:invalid, options}) do
    IO.puts "Invalid options: #{inspect options}"
    process :help
  end
  defp process({:unknown, argv}) do
    IO.puts "Unknown options: #{inspect argv}"
    process :help
  end

  defp file_changed?(_path) do
    # TODO: Keep track of the last run and ignore any files modified before then.
    # What about using different patterns?
    # Should I instead keep track of individual files?
    # http://stackoverflow.com/questions/22941948/how-does-gnu-make-keep-track-of-file-changes
    # I don't have the convenience of target files.

    true
  end

  defp options_to_map(options) do
    Enum.reduce(options, %{}, fn {key, value}, acc ->
      list = Map.get acc, key, []
      new_list = [value | list]
      Map.put acc, key, new_list
    end)
  end

  defp print_help do
    options = Flag.flags |> Enum.map(&Flag.format/1)
    IO.puts """
    Usage: jenny_lite [options] [file pattern]

    Options:
    #{options}
    """
  end
end
