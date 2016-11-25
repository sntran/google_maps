defmodule GoogleMaps do
  @moduledoc """
  Provides various map-related functionality.

  Unless otherwise noted, all the functions take the required Google 
  parameters as its own  parameters, and all optional ones in an 
  `options` keyword list.
  """

  use HTTPoison.Base

  @typedoc """
  An address that will be geocoded and converted to latitude/longitude
  coordinate.
  """
  @type address :: String.t

  @type latitude :: number
  @type longitude :: number
  @typedoc """
  A latitude/longitude pair in tuple or comma-separated string format.
  """
  @type coordinate :: {latitude(), longitude()} | String.t
  @typedoc """
  A tagged tuple with an ID of a known place.
  """
  @type place_id :: {:place_id, String.t}
  @typedoc """
  A specific point, which can be an address, a latitude/longitude coord
  or a place id tupple.
  """
  @type waypoint :: address() | coordinate() | place_id()

  @type mode :: String.t

  @type status :: String.t

  @type error :: HTTPoison.Error.t | status()

  def process_url(url) do
    %{path: path, query: query} = URI.parse(url)
    "https://maps.googleapis.com/maps/api/#{path}/json?key=AIzaSyDnPCkQMDmfgneX6juLvQ6rjBF98lyG5T0&#{query}"
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  def get(endpoint, params) do
    get("#{endpoint}?#{URI.encode_query(params)}")
  end

  @doc ~S"""
  Retrives the directions from one point to the other.

  Args:
    * `origin` — The address, textual latitude/longitude value, or 
      place ID from which you wish to calculate directions. If you pass
      an address, the Directions service geocodes the string and 
      converts it to a latitude/longitude coordinate to calculate 
      directions. This coordinate may be different from that returned 
      by the Google Maps Geocoding API, for example a building entrance
      rather than its center. Place IDs must be prefixed with 
      `place_id:`. The place ID may only be specified if the request 
      includes an API key or a Google Maps APIs Premium Plan client ID.
      You can retrieve place IDs from the Google Maps Geocoding API and
      the Google Places API (including Place Autocomplete).
    * `destination` — The address, textual latitude/longitude value, or
      place ID to which you wish to calculate directions. The options 
      for the destination parameter are the same as for the origin 
      parameter, described above.

  Options:
    * `mode` (defaults to driving) — Specifies the mode of transport to
      use when calculating directions. Valid values and other request 
      details are specified in Travel Modes section.
    * `waypoints`— Specifies an array of waypoints. Waypoints alter a 
      route by routing it through the specified location(s). A waypoint
      is specified as a latitude/longitude coordinate, an encoded 
      polyline, a place ID, or an address which will be geocoded. 
      Encoded polylines must be prefixed with enc: and followed by a 
      colon (:). Place IDs must be prefixed with place_id:. The place 
      ID may only be specified if the request includes an API key or 
      a Google Maps APIs Premium Plan client ID. Waypoints are only 
      supported for driving, walking and bicycling directions.
    * `alternatives` — If set to true, specifies that the Directions 
      service may provide more than one route alternative in the 
      response. Note that providing route alternatives may increase the
      response time from the server.
    * `avoid` — Indicates that the calculated route(s) should avoid the
      indicated features. Supports the following arguments:
      * `tolls` indicates that the calculated route should avoid toll
        roads/bridges.
      * `highways` indicates that the calculated route should avoid 
        highways.
      * `ferries` indicates that the calculated route should avoid 
        ferries.
      * `indoor` indicates that the calculated route should avoid 
        indoor steps for walking and transit directions. Only requests 
        that include an API key or a Google Maps APIs Premium Plan 
        client ID will receive indoor steps by default.
    * `language` — The language in which to return results.
      * See the list of [supported languages](https://developers.google.com/maps/faq#languagesupport).
      * If `language` is not supplied, the API attempts to use the 
        preferred language as specified in the `language` config, or 
        the native language of the domain from which request is sent.
      * If a name is not available in the preferred language, the API 
        uses the closest match.
      * The preferred language has a small influence on the set of 
        results that the API chooses to return, and the order in which 
        they are returned. The geocoder interprets abbreviations 
        differently depending on language, such as the abbreviations 
        for street types, or synonyms that may be valid in one 
        language but not in another. For example, utca and tér are 
        synonyms for street in Hungarian.
    * `units` — Specifies the unit system to use displaying results.
    * `region` — Specifies the region code, specified as a ccTLD 
      ("top-level domain") two-character value.
    * `arrival_time` — Specifies the desired time of arrival for 
      transit directions, in seconds since midnight, January 1, 1970 
      UTC. You can specify either `departure_time` or `arrival_time`, 
      but not both. Note that arrival_time must be specified as an 
      integer.
    * `departure_time` — Specifies the desired time of departure. You 
      can specify the time as an integer in seconds since midnight, 
      January 1, 1970 UTC. Alternatively, you can specify a value of 
      `now`, which sets the departure time to the current time (correct 
      to the nearest second). The departure time may be specified in 
      two cases:
      * For requests where the travel mode is transit: You can 
        optionally specify one of `departure_time` or `arrival_time`. 
        If neither time is specified, the `departure_time` defaults to 
        now (that is, the departure time defaults to the current time).
      * For requests where the travel mode is driving: You can specify 
        the `departure_time` to receive a route and trip duration 
        (response field: `duration_in_traffic`) that take traffic 
        conditions into account. This option is only available if the 
        request contains a valid API key, or a valid Google Maps APIs 
        Premium Plan client ID and signature. The `departure_time` must
        be set to the current time or some time in the future. It 
        cannot be in the past.
    * `traffic_model` (defaults to `best_guess`) — Specifies the 
      assumptions to use when calculating time in traffic. This setting
      affects the value returned in the `duration_in_traffic` field in 
      the response, which contains the predicted time in traffic based 
      on historical averages. The `traffic_model` parameter may only be
      specified for driving directions where the request includes a 
      `departure_time`, and only if the request includes an API key or 
      a Google Maps APIs Premium Plan client ID. The available values 
      for this parameter are:
      * `best_guess` (default) indicates that the returned 
        `duration_in_traffic` should be the best estimate of travel 
        time given what is known about both historical traffic 
        conditions and live traffic. Live traffic becomes more 
        important the closer the `departure_time` is to now.
      * `pessimistic` indicates that the returned `duration_in_traffic`
        should be longer than the actual travel time on most days, 
        though occasional days with particularly bad traffic conditions
        may exceed this value.
      * `optimistic indicates that the returned `duration_in_traffic` 
        should be shorter than the actual travel time on most days, 
        though occasional days with particularly good traffic 
        conditions may be faster than this value.
      The default value of `best_guess` will give the most useful 
      predictions for the vast majority of use cases. The `best_guess` 
      travel time prediction may be shorter than `optimistic`, or 
      alternatively, longer than `pessimistic`, due to the way the 
      `best_guess` prediction model integrates live traffic information.

  This function returns `{:ok, body}` if the request is successful, and
  Google returns data. It returns `{:error, error}` when there is HTTP
  errors, or `{:error, status}` when the request is successful, but 
  Google returns status codes different than "OK", i.e.:
    * "NOT_FOUND" 
    * "ZERO_RESULTS" 
    * "MAX_WAYPOINTS_EXCEEDED" 
    * "INVALID_REQUEST"
    * "OVER_QUERY_LIMIT"
    * "REQUEST_DENIED"
    * "UNKNOWN_ERROR"
  """
  @spec directions(waypoint(), waypoint(), keyword()) :: {:ok, map()} | {:error, error()}
  def directions(origin, destination, options \\ []) do
    params = [origin: origin, destination: destination]
    params = Enum.into(options, params, &transform_param/1)

    get("directions", params)
    |> case do
      {:error, error} -> {:error, error}
      {:ok, %{body: %{"status" => "OK"} = body}} -> {:ok, body}
      {:ok, %{body: %{"status" => status}}} -> {:error, status}
    end
  end

  defp transform_param({:waypoints, "enc:" <> enc}) do
    {:waypoints, "enc:" <> enc}
  end
  defp transform_param({:waypoints, waypoints}) when is_list(waypoints) do
    transform_param({:waypoints, Enum.join(waypoints, "|")})
  end
  defp transform_param({:waypoints, waypoints}) do
    # @TODO: Encode the waypoints into encoded polyline.
    {:waypoints, "optimize:true|#{waypoints}"}
  end
  defp transform_param(param), do: param
end