defmodule JennyLite.Expander.Test do
  use ExUnit.Case
  doctest JennyLite.Expander

  alias JennyLite.Expander

  test "expand" do
    expected = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_INLINE>>>
      {
        "template": "test.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<EXPAND_INLINE>>> */
      private let success = "It works!"
      /* <<<END_EXPAND_INLINE>>> */
    }
    """
    file = Path.join __DIR__, "test.swift"
    assert expected == Expander.expand file
  end
end
