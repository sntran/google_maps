defmodule DistanceTest do
  use ExUnit.Case, async: true
  alias GoogleMaps, as: Maps

  test "distance between two addresses" do
    origin = "Cột mốc Quốc Gia, Đất Mũi, Ca Mau, Vietnam"
    destination = "Cột cờ Lũng Cú, Đường lên Cột Cờ, Lũng Cú, Ha Giang, Vietnam"

    {:ok, result} = Maps.distance(origin, destination)
    assert_num_destination_addresses result, 1
    assert_num_rows result, 1

    %{"rows" => [row]} = result
    assert_num_elements_for_row row, 1
    %{"elements" => [element]} = row

    %{
      "distance" => %{"text" => distance_text, "value" => distance_value},
      "duration" => %{"text" => duration_text, "value" => duration_value},
      "status" => status
    } = element

    assert "OK" == status
    assert is_binary(distance_text)
    assert is_integer(distance_value)
    assert is_binary(distance_text)
    assert is_integer(distance_value)
  end

  test "distance between lat/lng tupples" do
    origin = {8.6069305,104.7196242}
    destination = {23.363697,105.3140251}

    {:ok, result} = Maps.distance(origin, destination)
    assert_num_destination_addresses result, 1
    assert_num_rows result, 1

    %{"rows" => [row]} = result
    assert_num_elements_for_row row, 1
    %{"elements" => [element]} = row

    %{
      "distance" => %{"text" => distance_text, "value" => distance_value},
      "duration" => %{"text" => duration_text, "value" => duration_value},
      "status" => status
    } = element

    assert "OK" == status
    assert is_binary(distance_text)
    assert is_integer(distance_value)
    assert is_binary(distance_text)
    assert is_integer(distance_value)
  end

  test "distance between one origin and two destinations using lat/lng tupples" do
    origin = {8.6069305,104.7196242}
    destinations = [{23.363697,105.3140251}, {22.593417, 104.617724}]

    {:ok, result} = Maps.distance(origin, destinations)
    assert_num_destination_addresses result, 2
    assert_num_rows result, 1

    %{"rows" => [row]} = result
    assert_num_elements_for_row row, 2

    %{"elements" => elements} = row
    [first_element | [last_element]] = elements

    %{
      "distance" => %{"text" => first_distance_text, "value" => first_distance_value},
      "duration" => %{"text" => first_duration_text, "value" => first_duration_value},
      "status" => first_status
    } = first_element
    assert "OK" == first_status
    assert is_binary(first_distance_text)
    assert is_integer(first_distance_value)
    assert is_binary(first_distance_text)
    assert is_integer(first_distance_value)

    %{
      "distance" => %{"text" => second_distance_text, "value" => second_distance_value},
      "duration" => %{"text" => second_duration_text, "value" => second_duration_value},
      "status" => second_status
    } = last_element
    assert "OK" == second_status
    assert is_binary(second_distance_text)
    assert is_integer(second_distance_value)
    assert is_binary(second_distance_text)
    assert is_integer(second_distance_value)
  end

  test "distance between two origins and one destination using lat/lng tupples" do
    destination = {8.6069305,104.7196242}
    origins = [{23.363697,105.3140251}, {22.593417, 104.617724}]

    {:ok, result} = Maps.distance(origins, destination)
    assert_num_destination_addresses result, 1
    assert_num_rows result, 2

    %{"rows" => [first_row | [last_row]]} = result
    assert_num_elements_for_row first_row, 1
    assert_num_elements_for_row last_row, 1

    %{"elements" => [first_row_element]} = first_row
    %{"elements" => [last_row_element]} = last_row

    %{
      "distance" => %{"text" => first_row_distance_text, "value" => first_row_distance_value},
      "duration" => %{"text" => first_row_duration_text, "value" => first_row_duration_value},
      "status" => first_row_status
    } = first_row_element
    assert "OK" == first_row_status
    assert is_binary(first_row_distance_text)
    assert is_integer(first_row_distance_value)
    assert is_binary(first_row_duration_text)
    assert is_integer(first_row_duration_value)

    %{
      "distance" => %{"text" => last_row_distance_text, "value" => last_row_distance_value},
      "duration" => %{"text" => last_row_duration_text, "value" => last_row_duration_value},
      "status" => last_row_status
    } = last_row_element
    assert "OK" == last_row_status
    assert is_binary(last_row_distance_text)
    assert is_integer(last_row_distance_value)
    assert is_binary(last_row_duration_text)
    assert is_integer(last_row_duration_value)
  end

  defp assert_num_destination_addresses(%{"destination_addresses" => addresses}, expected_count) when is_list(addresses) do
    assert Enum.count(addresses) == expected_count
  end

  defp assert_num_rows(%{"rows" => rows}, expected_count) when is_list(rows) do
    assert Enum.count(rows) == expected_count
  end

  defp assert_num_elements_for_row(%{"elements" => elements}, expected_count) when is_list(elements) do
    assert Enum.count(elements) == expected_count
  end
end
