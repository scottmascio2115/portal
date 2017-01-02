defmodule Portal do
  use Application
  defstruct [:left, :right]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Portal.Door, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: Portal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc"""
  Starts transfering data from left to right.
  """
  def transfer(left, right, data) do
    # First add all data to the portal on the left
    for item <- data do
      Portal.Door.push(left, item)
    end

    # Returns a portal struct we will use next
    %Portal{left: left, right: right}
  end

  @doc"""
  Pushes data to the right in the given portal.
  """
  def push_right(portal) do
    # See if we can pop data from left. If so, push the
    # popped data to the right. Otherwise do nothing.

    case Portal.Door.pop(portal.left) do
      :error -> :ok
      {:ok, h} -> Portal.Door.push(portal.right, h)
    end

    # Lets return the portal itself
    portal
  end

  @doc """
  Shoots a new door with the given `color`.

  The function above reaches the supervisor named Portal.Supervisor
  and asks for a new child to be started. Portal.Supervisor is the
  name of the supervisor we have defined in start/2 and the child
  is going to be a Portal.Door which was specified as a worker of
  that supervisor.

  Internally, to start the child, the supervisor will invoke Portal.Door.start_link(color),
  where color is the value passed on the start_child/2 call above.
  If we had invoked  Supervisor.start_child(Portal.Supervisor, [foo, bar, baz]),
  the supervisor would have attempted to start a child with Portal.Door.start_link(foo, bar, baz).
  """
  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end
end

# # Start doors
# iex> Portal.Door.start_link(:orange)
# {:ok, #PID<0.59.0>}
# iex> Portal.Door.start_link(:blue)
# {:ok, #PID<0.61.0>}
#
# # Start transfer
# iex> portal = Portal.transfer(:orange, :blue, [1, 2, 3])
# %Portal{left: :orange, right: :blue}
#
# # Check there is data on the orange/left door
# iex> Portal.Door.get(:orange)
# [3, 2, 1]
#
# # Push right once
# iex> Portal.push_right(portal)
# %Portal{left: :orange, right: :blue}
#
# # See changes
# iex> Portal.Door.get(:orange)
# [2, 1]
# iex> Portal.Door.get(:blue)
# [3]


## Final implementation

# iex> Portal.shoot(:orange)
# {:ok, #PID<0.72.0>}
# iex> Portal.shoot(:blue)
# {:ok, #PID<0.74.0>}
# iex> portal = Portal.transfer(:orange, :blue, [1, 2, 3, 4])
# #Portal<
#        :orange <=> :blue
#   [1, 2, 3, 4] <=> []
# >
#
# iex> Portal.push_right(portal)
# #Portal<
#     :orange <=> :blue
#   [1, 2, 3] <=> [4]
# >
