defmodule JennyLite.Template do
  defstruct path: "", inputs: %{}

  def new(path, inputs) do
    %__MODULE__{path: path, inputs: inputs}
  end

  def bindings(%__MODULE__{inputs: inputs}) do
    inputs
    |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(Keyword.new)
  end
end
