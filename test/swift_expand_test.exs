defmodule JennyLite.Expander.Test do
  use ExUnit.Case
  doctest JennyLite.Expander

  alias JennyLite.Expander

  test "expand" do
    initial = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_SPEC>>>
      {
        "template": "test.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<START_EXPAND>>> */
      private let willBeOverriden = true
      /* <<<END_EXPAND>>> */
    }
    """
    expanded = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_SPEC>>>
      {
        "template": "test.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<START_EXPAND>>> */
      private let success = "It works!"
      /* <<<END_EXPAND>>> */
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

      /* <<<EXPAND_SPEC>>>
      {
        "template": "nested.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<START_EXPAND>>> */
      private let willBeOverriden = true
      /* <<<END_EXPAND>>> */
    }
    """
    expanded = """
    public final class Test {

      private let answer = 42

      /* <<<EXPAND_SPEC>>>
      {
        "template": "nested.swift.template",
        "inputs": {
          "value": "It works!"
        }
      }
      <<<START_EXPAND>>> */
      private let success = "It works!"
      /* <<<END_EXPAND>>> */
    }
    """
    file = Path.join __DIR__, "test.swift"
    File.write! file, initial
    assert expanded != File.read! file
    assert :ok == Expander.expand_file file
    assert expanded == File.read! file
  end
end
