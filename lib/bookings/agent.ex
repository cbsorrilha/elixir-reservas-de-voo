defmodule Flightex.Bookings.Agent do
  alias Flightex.Bookings.Booking

  use Agent

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%Booking{id: id} = booking) do
    Agent.update(__MODULE__, &update_state(&1, id, booking))
    {:ok, id}
  end

  def list_all, do: Agent.get(__MODULE__, & &1)

  defp update_state(state, id, %Booking{} = booking), do: Map.put(state, id, booking)

  def get(id), do: Agent.get(__MODULE__, &get_booking(&1, id))

  defp get_booking(state, id) do
    case Map.get(state, id) do
      nil -> {:error, "Booking not found"}
      booking -> {:ok, booking}
    end
  end
end
