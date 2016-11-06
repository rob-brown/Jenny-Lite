defmodule JennyLite.Expander do
  alias JennyLite.{Template}

  def expand_file(file) when is_binary(file) do
    file
    |> Path.expand
    |> File.stream!
    |> expand_lines(Path.dirname file)
  end

  def expand_string(string, relative_to) when is_binary(string) and is_binary(relative_to) do
    string
    |> String.split("\n")
    |> Stream.map(& &1 <> "\n")
    |> expand_lines(relative_to)
  end

  defp expand_lines(lines, relative_to) do
    lines
    |> Enum.reduce({[], nil, :normal}, &find_expansions/2)
    |> (fn {lines, nil, :normal} -> Enum.reverse lines end).()
    |> Enum.map(& expand_template &1, relative_to)
    |> :erlang.iolist_to_binary
  end

  # TODO: Change this to use improper lists to avoid the reverse.
  defp find_expansions(line, {lines, json_lines, state}) do
    cond do
      state == :normal and line =~ ~r"^\s*/\*\s*<<<EXPAND_INLINE>>>\s*$" ->
        {[line | lines], [], :json}
      state == :json and line =~ ~r"^\s*<<<EXPAND_INLINE>>>\s*\*/\s*$" ->
        template = json_lines |> Enum.reverse |> new_template
        {[template, line | lines], nil, :drop}
      line =~ ~r"^\s*/\*\s*<<<END_EXPAND_INLINE>>>\s*\*/\s*$" ->
        {[line | lines], nil, :normal}
      state == :json ->
        {[line | lines], [line | json_lines], :json}
      state == :drop ->
        {lines, json_lines, :drop}
      state == :normal ->
        {[line | lines], json_lines, :normal}
    end
  end

  defp expand_template(template = %Template{}, relative_path) do

    # TODO: Recursively expand the code.

    full_path = Path.expand template.path, relative_path
    bindings = Template.bindings template
    EEx.eval_file full_path, bindings
  end
  defp expand_template(line, _), do: line

  defp new_template(json) do
    %{"template" => template, "inputs" => inputs} = Poison.decode! json
    Template.new template, inputs
  end
end
