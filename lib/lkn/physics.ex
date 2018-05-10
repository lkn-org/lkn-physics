alias Lkn.Physics.Geometry.Box
alias Lkn.Physics.Geometry.Vector

defmodule Lkn.Physics do
  @moduledoc false

  defmodule Body do
    defstruct [
      :position,
      :blocking,
      :box,
    ]

    @type t :: %Body{
      position: Vector.t,
      blocking: boolean,
      box: Box.t,
    }

    def new(vector, box, blocking \\ false) do
      %Body{
        position: vector,
        blocking: blocking,
        box: box
      }
    end

    defp minkowski_difference(a, b) do
      x = a.position.x - b.position.x - b.box.width
      y = a.position.y - b.position.y - b.box.height
      w = a.box.width + b.box.width
      h = a.box.height + b.box.height

      %Body{
        position: Vector.new(x, y),
        blocking: false,
        box: Box.new(w, h),
      }
    end

    defp contains(b, v) do
      v.x > b.position.x
      && v.x < b.position.x + b.box.width
      && v.y > b.position.y
      && v.y < b.position.y + b.box.height
    end

    def translate(body, v) do
      %Body{
        position: Vector.add(body.position, v),
        box: body.box,
      }
    end

    def collide?(b1, with: b2) do
      left = max(b1.position.x, b2.position.x)
      right = min(b1.position.x + b1.box.width, b2.position.x + b2.box.width)
      bottom = max(b1.position.y, b2.position.y)
      up = min(b1.position.y + b1.box.width, b2.position.y + b2.box.width)

      (left < right) && (bottom < up)
    end

    def collide_or_touch?(b1, with: b2) do
      left = max(b1.position.x, b2.position.x)
      right = min(b1.position.x + b1.box.width, b2.position.x + b2.box.width)
      bottom = max(b1.position.y, b2.position.y)
      up = min(b1.position.y + b1.box.width, b2.position.y + b2.box.width)

      (left <= right) && (bottom <= up)
    end

    defp possible_correction(vec) do
      vert = cond do
        vec.y > 0 -> [:bottom]
        vec.y < 0 -> [:top]
        true -> []
      end

      horiz = cond do
        vec.x > 0 -> [:left]
        vec.x < 0 -> [:right]
        true -> []
      end

      vert ++ horiz
    end

    defp direction(:top), do: :vert
    defp direction(:bottom), do: :vert
    defp direction(:right), do: :horiz
    defp direction(:left), do: :horiz

    def separate(b1, vec, from: b2) do
      b1 = translate(b1, vec)
      md = minkowski_difference(b2, b1)

      if contains(md, Vector.new(0, 0)) do
        # If the minwowski difference contains the nul vector, then b1 collides
        # with b2.

        if b2.blocking do
          # b2 blocks, so we therefore need to compute a vector to separate
          # them.
          top = md.position.y + md.box.height
          bottom = md.position.y
          left = md.position.x
          right = md.position.x + md.box.width

          # This pretty complicating snippet is here to prevent strange “jump”
          # of our bodies. Basically, the correction vector can only be in
          # opposition with the movement vector, it cannot amplify the movement.
          # TODO: swept aabb collision
          possible = possible_correction(vec)
          [choice|_] = [{:top, top}, {:bottom, bottom}, {:left, left}, {:right, right}]
                    |> Enum.reduce([], fn ({k, v}, res) ->
                         if Enum.member?(possible, k) do
                           [{direction(k), v}|res]
                         else
                           res
                         end
                       end)
                    |> Enum.sort_by(fn {_, v} -> abs(v) end)

          case choice do
            {:vert, val} -> {Vector.new(vec.x, vec.y +  val), true}
            {:horiz, val} -> {Vector.new(vec.x + val, vec.y), true}
          end
        else
          # b2 is not blocking, so vec is fine, but we did collide
          {vec, true}
        end
      else
        # Otherwise, vec is fine
        {vec, false}
      end
    end
  end

  defmodule World do
    defstruct [
      :bodies,
    ]

    @type t :: %World{
      bodies: %{any => Body.t}
    }

    def new() do
      %World{
        bodies: Map.new()
      }
    end

    def new(w, h) do
      world = new()

      vert_bound_box = Box.new(w, 2 * h)
      hori_bound_box = Box.new(w, h)

      world |> add(:right_bound, Body.new(Vector.new(w, -1 * h), vert_bound_box, true))
            |> add(:top_bound, Body.new(Vector.new(0, h), hori_bound_box, true))
            |> add(:left_bound, Body.new(Vector.new(-1 * w, -1 * h), vert_bound_box, true))
            |> add(:bottom_bound, Body.new(Vector.new(0, -1 * h), hori_bound_box, true))
    end

    def add(world, key, body) do
      %World{world|
             bodies: Map.put(world.bodies, key, body)
      }
    end

    def remove(world, key) do
      %World{world|
             bodies: Map.delete(world.bodies, key)
      }
    end

    defp fetch_position(body) do
      case body.position do
        %Vector{} -> body
        _ -> %Body{body|position: body.position.()}
      end
    end

    def move(world, key, vector) do
      {body, bodies} = Map.pop(world.bodies, key)
      body = fetch_position(body)

      Enum.reduce(bodies, {vector, []}, fn ({k, v}, {vec, col}) ->
        v = fetch_position(v)
        {vec, is_colliding} = Body.separate(body, vec, from: v)

        {vec, if(is_colliding, do: [k|col], else: col)}
      end)
    end
  end
end
