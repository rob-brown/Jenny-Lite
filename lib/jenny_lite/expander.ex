defmodule JennyLite.Expander do
  alias JennyLite.{Template}

  def expand(file) do
    dir = Path.dirname file
    file
    |> Path.expand
    |> File.stream!
    |> Enum.reduce({[], nil, :normal}, &find_expansions/2)
    |> (fn {lines, nil, :normal} -> Enum.reverse lines end).()
    |> Enum.map(& expand_template dir, &1)
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

  defp expand_template(relative_path, template = %Template{}) do

    # TODO: Recursively expand the code.

    full_path = Path.expand template.path, relative_path
    bindings = Template.bindings template
    EEx.eval_file full_path, bindings
  end
  defp expand_template(_, line), do: line

  defp new_template(json) do
    %{"template" => template, "inputs" => inputs} = Poison.decode! json
    Template.new template, inputs
  end
end
