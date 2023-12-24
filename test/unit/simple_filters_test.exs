defmodule SimpleFiltersTest.Unit.SimpleFilters do
  use ExUnit.Case

  import Dummy

  test "parse_integer/1" do
    assert SimpleFilters.parse_integer("3") == 3
  end

  test "parse_integer/1 with an non-parseable value" do
    assert SimpleFilters.parse_integer("hello") == 0
  end

  test "parse_integer/1 with an integer" do
    assert SimpleFilters.parse_integer(3) == 3
  end

  test "get_column/2" do
    assert SimpleFilters.get_column("name", []) == :name
  end

  test "get_column/2 with an option" do
    assert SimpleFilters.get_column("name", column: :other) == :other
  end

  test "cut_operator/1" do
    dummy String, [{"slice/2", :slice}] do
      result = SimpleFilters.cut_operator("xvalue")
      assert called(String.slice("xvalue", 1..-1//1))
      assert result == :slice
    end
  end
end
