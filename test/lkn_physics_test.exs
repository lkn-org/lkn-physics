alias Lkn.Physics.Body
alias Lkn.Physics.World

alias Lkn.Physics.Geometry.Box
alias Lkn.Physics.Geometry.Vector

defmodule LknPhysicsTest do
  use ExUnit.Case

  test "world and everything" do
    b = Box.new(10, 10)

    v1 = Vector.new(15, 10)
    v2 = Vector.new(32, 10)

    max = Body.new(v1, b)
    sam = Body.new(v2, b, true)

    world = World.new(100, 100)
            |> World.add("max", max)
            |> World.add("sam", sam)

    {new_pos, world} = World.move(world, "max", Vector.new(5, 2))

    assert new_pos.x == 20
    assert new_pos.y == 12

    {new_pos, world} = World.move(world, "max", Vector.new(5, 2))

    assert new_pos.x == 22
    assert new_pos.y == 14

    {new_pos, world} = World.move(world, "max", Vector.new(5, 2))

    assert new_pos.x == 22
    assert new_pos.y == 16

    {new_pos, world} = World.move(world, "max", Vector.new(5, 2))

    assert new_pos.x == 22
    assert new_pos.y == 18

    {new_pos, world} = World.move(world, "max", Vector.new(5, 2))

    assert new_pos.x == 22
    assert new_pos.y == 20
  end
end
