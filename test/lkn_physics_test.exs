alias Lkn.Physics.Body
alias Lkn.Physics.World

alias Lkn.Physics.Geometry.Box
alias Lkn.Physics.Geometry.Vector

defmodule LknPhysicsTest do
  use ExUnit.Case

  test "world and everything" do
    b = Box.new(10, 10)

    {:ok, a1} = Agent.start_link(fn -> Vector.new(15, 10) end)
    {:ok, a2} = Agent.start_link(fn -> Vector.new(32, 10) end)

    v1 = fn () -> Agent.get(a1, & &1) end
    v2 = fn () -> Agent.get(a2, & &1) end

    max = Body.new(v1, b)
    sam = Body.new(v2, b, true)

    world = World.new(100, 100)
            |> World.add("max", max)
            |> World.add("sam", sam)

    move_vec = World.move(world, "max", Vector.new(5, 2))

    assert move_vec.x == 5
    assert move_vec.y == 2

    Agent.update(a1, & Vector.add(&1, move_vec))

    move_vec = World.move(world, "max", Vector.new(5, 2))

    assert move_vec.x == 2
    assert move_vec.y == 2

    Agent.update(a1, & Vector.add(&1, move_vec))

    move_vec = World.move(world, "max", Vector.new(5, 2))

    assert move_vec.x == 0
    assert move_vec.y == 2

    Agent.update(a1, & Vector.add(&1, move_vec))

    move_vec = World.move(world, "max", Vector.new(5, 2))

    assert move_vec.x == 0
    assert move_vec.y == 2

    Agent.update(a1, & Vector.add(&1, move_vec))

    move_vec = World.move(world, "max", Vector.new(5, 2))

    assert move_vec.x == 0
    assert move_vec.y == 2
  end
end
