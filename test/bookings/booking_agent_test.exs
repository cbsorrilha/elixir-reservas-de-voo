defmodule Flightex.Bookings.AgentTest do
  use ExUnit.Case

  import Flightex.Factory

  alias Flightex.Bookings.Agent, as: BookingsAgent

  describe "save/1" do
    setup do
      BookingsAgent.start_link(%{})

      :ok
    end

    test "when the param are valid, return a booking uuid" do
      response =
        :booking
        |> build()
        |> BookingsAgent.save()

      {_ok, uuid} = response

      assert response == {:ok, uuid}
    end
  end

  describe "get/1" do
    setup do
      BookingsAgent.start_link(%{})

      {:ok, id: UUID.uuid4()}
    end

    test "when the user is found, return a booking", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, uuid} = BookingsAgent.save(booking)

      response = BookingsAgent.get(uuid)

      expected_response =
        {:ok,
         %Flightex.Bookings.Booking{
           complete_date: ~N[2001-05-07 03:05:00],
           id: id,
           local_destination: "Bananeiras",
           local_origin: "Brasilia",
           user_id: "12345678900"
         }}

      assert response == expected_response
    end

    test "when the user wasn't found, returns an error", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, _uuid} = BookingsAgent.save(booking)

      response = BookingsAgent.get("banana")

      expected_response = {:error, "Booking not found"}

      assert response == expected_response
    end
  end

  describe "list_all/0" do
    setup do
      BookingsAgent.start_link(%{})

      {:ok, id: UUID.uuid4(), id2: UUID.uuid4()}
    end

    test "when there are users, return a map of bookings", %{id: id, id2: id2} do
      booking = build(:booking, id: id)
      booking2 = build(:booking, id: id2)
      {:ok, uuid} = BookingsAgent.save(booking)
      {:ok, uuid2} = BookingsAgent.save(booking2)

      response = BookingsAgent.list_all()

      expected_response = %{
        uuid => %Flightex.Bookings.Booking{
          complete_date: ~N[2001-05-07 03:05:00],
          id: uuid,
          local_destination: "Bananeiras",
          local_origin: "Brasilia",
          user_id: "12345678900"
        },
        uuid2 => %Flightex.Bookings.Booking{
          complete_date: ~N[2001-05-07 03:05:00],
          id: uuid2,
          local_destination: "Bananeiras",
          local_origin: "Brasilia",
          user_id: "12345678900"
        }
      }

      assert expected_response == response
    end
  end

  describe "list_between_dates/2" do
    setup do
      BookingsAgent.start_link(%{})

      {:ok, id: UUID.uuid4(), id2: UUID.uuid4(), id3: UUID.uuid4()}
    end

    test "when there are users, return a map of bookings", %{id: id, id2: id2, id3: id3} do
      date1 = ~N[2001-04-07 03:05:00]
      date2 = ~N[2001-05-07 03:05:00]
      date3 = ~N[2001-05-30 03:05:00]
      booking = build(:booking, id: id)
      booking2 = build(:booking, id: id2)
      booking3 = build(:booking, id: id3, complete_date: date1)
      {:ok, _uuid} = BookingsAgent.save(booking)
      {:ok, _uuid2} = BookingsAgent.save(booking2)
      {:ok, _uuid3} = BookingsAgent.save(booking3)

      response = BookingsAgent.list_between_dates(date2, date3)

      expected_response = 2

      assert expected_response == Enum.count(response)
    end
  end
end
