defmodule GoogleMaps do
  @moduledoc """
  Provides various map-related functionality.

  Unless otherwise noted, all the functions take the required Google 
  parameters as its own  parameters, and all optional ones in an 
  `options` keyword list.
  """
  alias GoogleMaps.{Request, Response}

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
    * `mode` (defaults to "driving") — Specifies the mode of transport 
      to use when calculating directions. Valid values and other  
      request details are specified in Travel Modes section.
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
      * `optimistic` indicates that the returned `duration_in_traffic` 
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
  @spec directions(waypoint(), waypoint(), keyword()) :: Response.t()
  def directions(origin, destination, options \\ []) do
    params = options
    |> Keyword.merge([origin: origin, destination: destination])

    Request.get("directions", params)
    |> Response.wrap
  end

  @doc """
  Automatically fill in the name and/or address of a place.

  The Place Autocomplete service is a web service that returns place 
  predictions in response to an HTTP request. The request specifies a 
  textual search string and optional geographic bounds. The service 
  can be used to provide autocomplete functionality for text-based 
  geographic searches, by returning places such as businesses, 
  addresses and points of interest as a user types.

  The Place Autocomplete service can match on full words as well as 
  substrings. Applications can therefore send queries as the user 
  types, to provide on-the-fly place predictions.

  The returned predictions are designed to be presented to the user to 
  aid them in selecting the desired place. You can send a Place Details
  request for more information about any of the places returned.

  ## Args:
    * `input` — The text string on which to search. The Place 
      Autocomplete service will return candidate matches based on this 
      string and order results based on their perceived relevance.

  ## Options:
    * `offset` — The position, in the input term, of the last character
      that the service uses to match predictions. For example, if the 
      input is 'Google' and the `offset` is 3, the service will match 
      on 'Goo'. The string determined by the offset is matched against 
      the first word in the input term only. For example, if the input 
      term is 'Google abc' and the `offset` is 3, the service will 
      attempt to match against 'Goo abc'. If no offset is supplied, the
      service will use the whole term. The offset should generally be 
      set to the position of the text caret.
    * `location` — The point around which you wish to retrieve place 
      information. Must be specified as *latitude,longitude*.
    * `radius` — The distance (in meters) within which to return place 
      results. Note that setting a `radius` biases results to the 
      indicated area, but may not fully restrict results to the 
      specified area. See Location Biasing below.
    * `language` — The language code, indicating in which language the 
      results should be returned, if possible. Searches are also biased
      to the selected language; results in the selected language may be
      given a higher ranking. See the [list of supported languages](https://developers.google.com/maps/faq#languagesupport) 
      and their codes. Note that we often update supported languages so
      this list may not be exhaustive. If language is not supplied, the
      Place Autocomplete service will attempt to use the native 
      language of the domain from which the request is sent.
    * `types` — The types of place results to return. See Place Types 
      below. If no type is specified, all types will be returned.
    * `components` — A grouping of places to which you would like to 
      restrict your results. Currently, you can use `components` to 
      filter by country. The country must be passed as a two character,
      ISO 3166-1 Alpha-2 compatible country code. For example: 
      `components=country:fr` would restrict your results to places 
      within France.

  ## Location Biasing
  You may bias results to a specified circle by passing a `location` &
  a `radius` parameter. This instructs the Place Autocomplete service
  to *prefer* showing results within that circle. Results outside of
  the defined area may still be displayed. You can use the `components`
  parameter to filter results to show only those places within a 
  specified country.

  **Note**: If you do not supply the location and radius, the API will 
  attempt to detect the server's location from their IP address, and 
  will bias the results to that location. If you would prefer to have 
  no location bias, set the location to '0,0' and radius to '20000000' 
  (20 thousand kilometers), to encompass the entire world.

  *Tip*: Establishment results generally do not rank highly enough to 
  show in results when the search area is large. If you want 
  establishments to appear in mixed establishment/geocode results, you 
  can specify a smaller radius. Alternatively, use `types=establishment`
  to restrict results to establishments only.

  ## Place Types

  You may restrict results from a Place Autocomplete request to be of 
  a certain type by passing a `types` parameter. The parameter specifies 
  a type or a type collection, as listed in the supported types below. 
  If nothing is specified, all types are returned. In general only a 
  single type is allowed. The exception is that you can safely mix the
  `geocode` and `establishment` types, but note that this will have the
  same effect as specifying no types. The supported types are:

    * `geocode` instructs the Place Autocomplete service to return only 
      geocoding results, rather than business results. Generally, you 
      use this request to disambiguate results where the location 
      specified may be indeterminate.
    * `address` instructs the Place Autocomplete service to return only
      geocoding results with a precise address. Generally, you use this
      request when you know the user will be looking for a fully 
      specified address.
    * `establishment` instructs the Place Autocomplete service to 
      return only business results.
    * the `(regions)` type collection instructs the Places service to 
      return any result matching the following types:
      * `locality`
      * `sublocality`
      * `postal_code`
      * `country`
      * `administrative_area_level_1`
      * `administrative_area_level_2`
    * the `(cities)` type collection instructs the Places service to 
      return results that match `locality` or 
      `administrative_area_level_3`.

  ## Returns

  This function returns `{:ok, body}` if the request is successful, and
  Google returns data. The returned body is a map contains two root
  elements:
    * `status` contains metadata on the request.
    * `predictions` contains an array of places, with information about
      the place. See Place Autocomplete Results for information about 
      these results. The Google API returns up to 5 results.

  Of particular interest within the results are the place_id elements, 
  which can be used to request more specific details about the place 
  via a separate query. See Place Details Requests.

  It returns `{:error, error}` when there is HTTP
  errors, or `{:error, status}` when the request is successful, but 
  Google returns status codes different than "OK", i.e.:
    * "NOT_FOUND" 
    * "ZERO_RESULTS" 
    * "MAX_WAYPOINTS_EXCEEDED" 
    * "INVALID_REQUEST"
    * "OVER_QUERY_LIMIT"
    * "REQUEST_DENIED"
    * "UNKNOWN_ERROR"

  ## Place Autocomplete Results

  Each prediction result contains the following fields:

    * `description` contains the human-readable name for the returned 
      result. For `establishment` results, this is usually the business
      name.
    * `place_id` is a textual identifier that uniquely identifies a 
      place. To retrieve information about the place, pass this 
      identifier in the `placeId` field of a Google Places API request.
    * `terms` contains an array of terms identifying each section of 
      the returned description (a section of the description is
      generally terminated with a comma). Each entry in the array has 
      a value field, containing the text of the term, and an `offset` 
      field, defining the start position of this term in the 
      description, measured in Unicode characters.
    * `types` contains an array of types that apply to this place. For 
      example: [ "political", "locality" ] or [ "establishment", 
      "geocode" ].
    * `matched_substrings` contains an array with offset value and 
      length. These describe the location of the entered term in the 
      prediction result text, so that the term can be highlighted if 
      desired.

  **Note**: The Place Autocomplete response does not include the `scope` 
  or `alt_ids` fields that you may see in search results or place 
  details. This is because Autocomplete returns only Google-scoped 
  place IDs. It does not return app-scoped place IDs that have not yet 
  been accepted into the Google Places database. For more details about 
  Google-scoped and app-scoped place IDs, see the documentation on 
  [adding places](https://developers.google.com/places/web-service/add-place).

  ## Examples
    
      # Searching for "Paris"
      iex> {:ok, result} = GoogleMaps.place_autocomplete("Paris")
      iex> Enum.count(result["predictions"])
      5
      iex> [paris | _rest] = result["predictions"]
      iex> paris["description"]
      "Paris, France"
      iex> paris["place_id"]
      "ChIJD7fiBh9u5kcRYJSMaMOCCwQ"
      iex> paris["types"]
      [ "locality", "political", "geocode" ]

      # Establishments containing the string "Amoeba" within an area 
      # centered in San Francisco, CA:
      iex> {:ok, result} = GoogleMaps.place_autocomplete("Amoeba", [
      ...>   types: "establishment",
      ...>   location: "37.76999,-122.44696",
      ...>   radius: 500
      ...> ])
      iex> Enum.count(result["predictions"])
      5

      # Addresses containing "Vict" with results in French:
      iex> {:ok, result} = GoogleMaps.place_autocomplete("Vict", [
      ...>   types: "geocode",
      ...>   language: "fr"
      ...> ])
      iex> Enum.count(result["predictions"])
      5

      # Cities containing "Vict" with results in Brazilian Portuguese:
      iex> {:ok, result} = GoogleMaps.place_autocomplete("Vict", [
      ...>   types: "(cities)",
      ...>   language: "pt_BR"
      ...> ])
      iex> Enum.count(result["predictions"])
      5
  """
  @spec place_autocomplete(String.t, keyword()) :: Response.t()
  def place_autocomplete(input, options \\ []) do
    params = options
    |> Keyword.merge([input: input])
    
    Request.get("place/autocomplete", params)
    |> Response.wrap
  end
end