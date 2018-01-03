defmodule Lkn.Physics.Geometry do
  defmodule Vector do
    defstruct [
      :x,
      :y,
    ]

    @type t :: %Vector{
      x: number,
      y: number,
    }

    def new(x, y) do
      %Vector{
        x: x,
        y: y,
      }
    end

    def from_polar(r, alpha) do
      %Vector{
        x: r * :math.cos(alpha),
        y: r * :math.sin(alpha),
      }
    end

    def norm(v) do
      :math.sqrt(:math.pow(v.x, 2) + :math.pow(v.y, 2))
    end

    def add(v, u) do
      %Vector{
        x: v.x + u.x,
        y: v.y + u.y,
      }
    end

    def mul(a, v) do
      %Vector{
        x: a * v.x,
        y: a * v.y,
      }
    end
  end

  defmodule Box do
    defstruct [
      :width,
      :height,
    ]

    @type t :: %Box{
      width: non_neg_integer,
      height: non_neg_integer,
    }

    def new(w, h) do
      %Box{
        width: w,
        height: h,
      }
    end
  end
end
