defmodule CAIData.APITest do
  use ExUnit.Case
  doctest CAIData.API

  test "greets the world" do
    assert CAIData.API.hello() == :world
  end
end
