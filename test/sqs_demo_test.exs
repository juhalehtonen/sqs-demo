defmodule SQSDemoTest do
  use ExUnit.Case
  doctest SQSDemo

  test "greets the world" do
    assert SQSDemo.hello() == :world
  end
end
