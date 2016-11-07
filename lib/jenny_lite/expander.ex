defmodule JennyLite.Expander do
  alias JennyLite.{Template}

  def expand_file(file) when is_binary(file) do
    file
    |> Path.expand
    |> File.stream!
    |> expand_lines(Path.dirname file)
    |> (& File.write! file, &1).()
  end

  def expand_string(string, relative_to, include_config? \\ true) when is_binary(string) and is_binary(relative_to) and is_boolean(include_config?) do
    string
    |> String.split("\n")
    |> Stream.map(& &1 <> "\n")
    |> expand_lines(relative_to, include_config?)
  end

  defp expand_lines(lines, relative_to, include_config? \\ true) do
    lines
    |> Enum.reduce({[], nil, :normal}, find_expansions(include_config?))
    |> (fn {lines, nil, :normal} -> Enum.reverse lines end).()
    |> Enum.map(& expand_template &1, relative_to)
  end

  # TODO: Change this to use improper lists to avoid the reverse.
  defp find_expansions(include_config?) do
    fn line, {lines, json_lines, state} ->
      cond do
        state == :normal and line =~ ~r"^\s*/\*\s*<<<EXPAND_INLINE>>>\s*$" ->
          if include_config? do
            {[line | lines], [], :json}
          else
            {lines, [], :json}
          end
        state == :json and line =~ ~r"^\s*<<<EXPAND_INLINE>>>\s*\*/\s*$" ->
          template = json_lines |> Enum.reverse |> new_template
          if include_config? do
            {[template, line | lines], nil, :drop}
          else
            {[template | lines], nil, :drop}
          end
        line =~ ~r"^\s*/\*\s*<<<END_EXPAND_INLINE>>>\s*\*/\s*$" ->
          if include_config? do
            {[line | lines], nil, :normal}
          else
            {lines, nil, :normal}
          end
        state == :json and include_config? ->
          {[line | lines], [line | json_lines], :json}
        state == :json ->
          {lines, [line | json_lines], :json}
        state == :drop ->
          {lines, json_lines, :drop}
        state == :normal ->
          {[line | lines], json_lines, :normal}
      end
    end
  end

  defp expand_template(template = %Template{}, relative_path) do
    full_path = Path.expand template.path, relative_path
    bindings = Template.bindings template
    expanded = EEx.eval_file full_path, bindings, trim: true
    dir = Path.dirname full_path

    # Recursively expand.
    expanded
    |> :erlang.iolist_to_binary
    |> expand_string(dir, false )
  end
  defp expand_template(line, _), do: line

  defp new_template(json) do
    %{"template" => template, "inputs" => inputs} = Poison.decode! json
    Template.new template, inputs
  end
end
