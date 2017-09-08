defmodule GoogleMaps.Request do
  @moduledoc false

  use HTTPoison.Base

  defp api_key do
    Application.get_env(:google_maps, :api_key) || 
      System.get_env("GOOGLE_MAPS_API_KEY")
  end

  @doc """
  GET an endpoint with param keyword list
  """
  @spec get(String.t, keyword()) :: GoogleMaps.Response.t
  def get(endpoint, params) do
    params =
      [key: api_key()]
      |> Keyword.merge(params)
      |> Enum.map(&transform_param/1)
    get("#{endpoint}?#{URI.encode_query(params)}")
  end

  # HTTPoison callbacks.
  def process_url(url) do
    %{path: path, query: query} = URI.parse(url)
    "https://maps.googleapis.com/maps/api/#{path}/json?#{query}"
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  # Helpers

  defp transform_param({type, {lat, lng}})
  when type in [:origin, :destination]
  and is_number(lat)
  and is_number(lng)
  do
    {type, "#{lat},#{lng}"}
  end

  defp transform_param({type, {:place_id, place_id}})
  when type in [:origin, :destination]
  do
    {type, "place_id:#{place_id}"}
  end

  defp transform_param({:waypoints, "enc:" <> enc}) do
    {:waypoints, "enc:" <> enc}
  end

  defp transform_param({:waypoints, waypoints})
  when is_list(waypoints) do
    transform_param({:waypoints, Enum.join(waypoints, "|")})
  end

  defp transform_param({:waypoints, waypoints}) do
    # @TODO: Encode the waypoints into encoded polyline.
    {:waypoints, "optimize:true|#{waypoints}"}
  end

  defp transform_param(param), do: param
end