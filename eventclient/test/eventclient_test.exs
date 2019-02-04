defmodule EventclientTest do
  use ExUnit.Case
  doctest Eventclient

  test "greets the world" do
    assert Eventclient.hello() == :world
  end
end
