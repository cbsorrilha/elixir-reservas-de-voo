defmodule Flightex.Bookings.Report do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking

  def generate(filename \\ "report.csv") do
    booking_list = BookingAgent.list_all()
      |> Map.values()
      |> build_booking_list()

    File.write(filename, booking_list)
  end

  def generate_report(from_date, to_date) do
    list = BookingAgent.list_between_dates(from_date, to_date)
    booking_list = build_booking_list(list)

    File.write(create_file_name(from_date, to_date), booking_list)
  end

  defp create_file_name(from_date, to_date) do
    "report#{NaiveDateTime.to_date(from_date)}to#{NaiveDateTime.to_date(to_date)}.csv"
  end

  defp build_booking_list(list) do
    list
    |> Enum.map(fn booking -> make_booking_line(booking) end)
  end

  defp make_booking_line(%Booking{
         complete_date: complete_date,
         local_origin: local_origin,
         local_destination: local_destination,
         user_id: user_id
       }) do
    "#{user_id},#{local_origin},#{local_destination},#{complete_date}\n"
  end
end
