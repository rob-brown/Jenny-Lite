defmodule JennyLite.Expander.Test do
  use ExUnit.Case
  doctest JennyLite.Expander

  alias JennyLite.Expander

  test "expand" do
    initial = """
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
      private let willBeOverriden = true
      /* <<<END_EXPAND_INLINE>>> */
    }
    """
    expanded = """
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
    File.write! file, initial
    assert expanded != File.read! file
    assert :ok == Expander.expand_file file
    assert expanded == File.read! file
  end

  test "recursive expand" do
    initial = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_INLINE>>>
      {
        "template": "nested.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<EXPAND_INLINE>>> */
      private let willBeOverriden = true
      /* <<<END_EXPAND_INLINE>>> */
    }
    """
    expanded = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_INLINE>>>
      {
        "template": "nested.swift.template",
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
    File.write! file, initial
    assert expanded != File.read! file
    assert :ok == Expander.expand_file file
    assert expanded == File.read! file
  end
end
