defmodule JennyLite.CLI.Flag do
  defstruct switch: nil, alias: nil, type: nil, description: ""

  def flags do
    [
      {:help, :h, :boolean, "Prints usage information."},
      {:file, :f, [:string, :keep], "Indicate a file or pattern for expansion. (*)"},
      {:ignore, :i, [:string, :keep], "Ignore a file or pattern from expansion. Overwrites files listed with `--file` (*)"},
    ]
    |> Enum.map(fn {s, a, t, d} -> %__MODULE__{switch: s, alias: a, type: t, description: d} end)
  end

  def switches do
    flags |> Enum.map(& {&1.switch, &1.type})
  end

  def aliases do
    flags |> Enum.map(& {&1.alias, &1.switch})
  end

  def format(flag = %__MODULE__{}) do
    :io_lib.format "  ~-12s ~-6s ~s\n", ["--#{flag.switch}", "-#{flag.alias}", flag.description]
  end
end
