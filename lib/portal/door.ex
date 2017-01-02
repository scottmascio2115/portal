defmodule Portal.Door do
  @doc"""
  An agent is abstraction that stores state.
  """

  @doc """
  Starts a door with the given `color`.

  The color is given as a name so we can identify
  the door by color name instead of using a PID.
  """
  def start_link(color) do
    Agent.start_link(fn -> [] end, name: color)
  end

  @doc """
  Get the data currently in the 'door'.
  """
  def get(door) do
    Agent.get(door, fn list -> list end)
  end

  @doc"""
  Pushes the 'value' into the door.
  """
  def push(door, value) do
    Agent.update(door, fn list -> [value|list] end)
  end

  @doc"""
  Pops a value from the door.
  Returns {:ok, value} if there is a value
  or ':error' if the hole is currently empty.
  """
  def pop(door) do
    Agent.get_and_update(door, fn
      [] -> {:error, []}
      [h|t] -> {{:ok, h}, t}
    end
  end
end

### Example usage

# iex> Portal.Door.start_link(:pink)
# {:ok, #PID<0.68.0>}
# iex> Portal.Door.get(:pink)
# []
# iex> Portal.Door.push(:pink, 1)
# :ok
# iex> Portal.Door.get(:pink)
# [1]
# iex> Portal.Door.pop(:pink)
# {:ok, 1}
# iex> Portal.Door.get(:pink)
# []
# iex> Portal.Door.pop(:pink)
# :error

###
