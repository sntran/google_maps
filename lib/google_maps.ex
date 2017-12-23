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

  @type options :: keyword()

  @type mode :: String.t

  @doc """
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
  errors, or `{:error, status, error_message}` when the request is successful, but
  Google returns status codes different than "OK", i.e.:
    * "NOT_FOUND"
    * "ZERO_RESULTS"
    * "MAX_WAYPOINTS_EXCEEDED"
    * "INVALID_REQUEST"
    * "OVER_QUERY_LIMIT"
    * "REQUEST_DENIED"
    * "UNKNOWN_ERROR"

  ## Examples

      # Driving directions with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.directions("Toronto", "Montreal", key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      # Driving directions from Toronto, Ontario to Montreal, Quebec.
      iex> {:ok, result} = GoogleMaps.directions("Toronto", "Montreal")
      iex> [route] = result["routes"]
      iex> route["bounds"]
      %{"northeast" => %{"lat" => 45.5017123, "lng" => -73.5672184},
      "southwest" => %{"lat" => 43.6533096, "lng" => -79.3834186}}

      # Directions for a scenic bicycle journey that avoids major highways.
      iex> {:ok, result} = GoogleMaps.directions("Toronto", "Montreal", [
      ...>   avoid: "highway",
      ...>   mode: "bicycling"
      ...> ])
      iex> [route] = result["routes"]
      iex> route["bounds"]
      %{"northeast" => %{"lat" => 45.5017123, "lng" => -73.563532},
      "southwest" => %{"lat" => 43.6532566, "lng" => -79.38303979999999}}

      # Transit directions from Brooklyn, New York to Queens, New York.
      # The request does not specify a `departure_time`, so the
      # departure time defaults to the current time:
      iex> {:ok, result} = GoogleMaps.directions("Brooklyn", "Queens", [
      ...>   mode: "transit"
      ...> ])
      iex> Enum.count(result["routes"])
      1

      # Driving directions from Glasgow, UK to Perth, UK using place IDs.
      iex> {:ok, result} = GoogleMaps.directions("place_id:ChIJ685WIFYViEgRHlHvBbiD5nE", "place_id:ChIJA01I-8YVhkgRGJb0fW4UX7Y")
      iex> Enum.count(result["routes"])
      1

      # Same driving directions above but using place ID tuples.
      iex> {:ok, result} = GoogleMaps.directions({:place_id, "ChIJ685WIFYViEgRHlHvBbiD5nE"}, {:place_id, "ChIJA01I-8YVhkgRGJb0fW4UX7Y"})
      iex> Enum.count(result["routes"])
      1
  """
  @spec directions(waypoint(), waypoint(), options()) :: Response.t()
  def directions(origin, destination, options \\ []) do
    params = options
    |> Keyword.merge([origin: origin, destination: destination])

    GoogleMaps.get("directions", params)
  end

  @doc """
  Finds the distance between two addresses.

  ## Args:
    * `origins` — The starting point for calculating travel distance and time.

    * `destinations` — The finishing point for calculating travel distance and time.

  ## Options:

    * `mode` (defaults to `driving`) — Specifies the mode of transport to use
      when calculating distance.

    * `language` — The language in which to return results.

    * `avoid` — Introduces restrictions to the route. Valid values are specified
      in the Restrictions section of this document. Only one restriction can be
      specified.

    * `units` — Specifies the unit system to use when expressing distance as
      text. See the Unit Systems section of this document for more information.

    * `arrival_time` — Specifies the desired time of arrival for transit
      requests, in seconds since midnight, January 1, 1970 UTC. You can specify
      either `departure_time` or `arrival_time`, but not both. Note that
      `arrival_time` must be specified as an integer.

    * `departure_time` — The desired time of departure. You can specify the time
      as an integer in seconds since midnight, January 1, 1970 UTC.
      Alternatively, you can specify a value of `now`, which sets the departure
      time to the current time (correct to the nearest second).

    * traffic_model (defaults to `best_guess`) — Specifies the assumptions to
      use when calculating time in traffic.

    * `transit_mode` — Specifies one or more preferred modes of transit.

    * `transit_routing_preference` — Specifies preferences for transit requests.

  This function returns `{:ok, body}` if the request is successful, and
  Google returns data. It returns `{:error, error}` when there is HTTP
  errors, or `{:error, status, error_message}` when the request is successful, but
  Google returns status codes different than "OK", i.e.:
  * "NOT_FOUND"
  * "ZERO_RESULTS"
  * "MAX_WAYPOINTS_EXCEEDED"
  * "INVALID_REQUEST"
  * "OVER_QUERY_LIMIT"
  * "REQUEST_DENIED"
  * "UNKNOWN_ERROR"

  ## Examples

      # Distance with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.distance("Place d'Armes, 78000 Versailles", "Champ de Mars, 5 Avenue Anatole", key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      # Distance from Eiffel Tower to Palace of Versailles.
      iex> {:ok, result} = GoogleMaps.distance("Place d'Armes, 78000 Versailles", "Champ de Mars, 5 Avenue Anatole")
      iex> result["destination_addresses"]
      ["Champ de Mars, 2 Allée Adrienne Lecouvreur, 75007 Paris, France"]
      iex> result["origin_addresses"]
      ["Place d'Armes, 78000 Versailles, France"]
      iex> [%{"elements" => [%{"distance" => distance}]}] = result["rows"]
      iex> distance["text"]
      "23.8 km"
      iex> distance["value"]
      23765
  """
  @spec distance(address(), address(), options()) :: Response.t()
  def distance(origin, destination, options \\ []) do
    params = options
    |> Keyword.merge([origins: origin, destinations: destination])

    GoogleMaps.get("distancematrix", params)
  end

  @doc """
  Converts between addresses and geographic coordinates.

  **Geocoding** is the process of converting addresses (like "1600
  Amphitheatre Parkway, Mountain View, CA") into geographic coordinates
  (like latitude 37.423021 and longitude -122.083739), which you can
  use to place markers on a map, or position the map.

  **Reverse geocoding** is the process of converting geographic
  coordinates into a human-readable address. The Google Maps
  Geocoding API's reverse geocoding service also lets you find the
  address for a given place ID.

  ## Args:

    * `address` — The street address that you want to geocode, in the
      format used by the national postal service of the country
      concerned. Additional address elements such as business names and
      unit, suite or floor numbers should be avoided.
    * ** or **
    * `components` — A component filter for which you wish to obtain a
      geocode. The `components` filter will also be accepted as an
      optional parameter if an address is provided.

    * --- Reverse geocoding ---
    * `latlng`: The latitude and longitude values specifying the
      location for which you wish to obtain the closest, human-readable
      address.
    * ** or **
    * `place_id` — The place ID of the place for which you wish to
      obtain the human-readable address. The place ID is a unique
      identifier that can be used with other Google APIs.

  ## Options:

    * `bounds` — The bounding box of the viewport within which to bias
      geocode results more prominently. This parameter will only
      influence, not fully restrict, results from the geocoder.

    * `language` — The language in which to return results.

    * `region` — The region code, specified as a ccTLD ("top-level
      domain") two-character value. This parameter will only influence,
      not fully restrict, results from the geocoder.

    * `components` — The component filters, separated by a pipe (|).
      Each component filter consists of a component:value pair and will
      fully restrict the results from the geocoder. For more
      information see Component Filtering.

    * `result_type` — One or more address types, separated by a pipe
      (`|`). Examples of address types: `country`, `street_address`,
      `postal_code`. For a full list of allowable values, see the
      address types. **Note** for reverse geocoding requests.

    * `location_type` — One or more location types, separated by a pipe
      (`|`). Specifying a type will restrict the results to this type.
      If multiple types are specified, the API will return all
      addresses that match any of the types. **Note** for reverse
      geocoding requests. The following values are supported:
        * "ROOFTOP" restricts the results to addresses for which we
          have location information accurate down to street address
          precision.
        * "RANGE_INTERPOLATED" restricts the results to those that
          reflect an approximation (usually on a road) interpolated
          between two precise points (such as intersections). An
          interpolated range generally indicates that rooftop geocodes
          are unavailable for a street address.
        * "GEOMETRIC_CENTER" restricts the results to geometric centers
          of a location such as a polyline (for example, a street) or
          polygon (region).
        * "APPROXIMATE" restricts the results to those that are
          characterized as approximate.

    If both `result_type` and `location_type` restrictions are present
    then the API will return only those results that matches both the
    `result_type` and the `location_type` restrictions.

  ## Returns

    This function returns `{:ok, body}` if the request is successful, and
    Google returns data. The returned body is a map contains two root
    elements:
      * `status` contains metadata on the request.
      * `results` contains an array of geocoded address information and
        geometry information.

    Generally, only one entry in the `results` array is returned for
    address lookups, though the geocoder may return several results when
    address queries are ambiguous. Reverse geocoder returns more than one
    result, from most specific to least specific.

    A typical result is made up of the following fields:

    * The `types[]` array indicates the *type* of the returned result.
      This array contains a set of zero or more tags identifying the
      type of feature returned in the result. For example, a geocode
      of "Chicago" returns "locality" which indicates that "Chicago"
      is a city, and also returns "political" which indicates it is a
      political entity.

    * `formatted_address` is a string containing the human-readable
      address of this location. Often this address is equivalent to
      the "postal address," which sometimes differs from country to
      country. (Note that some countries, such as the United Kingdom,
      do not allow distribution of true postal addresses due to
      licensing restrictions.) This address is generally composed of
      one or more address components. For example, the address "111
      8th Avenue, New York, NY" contains separate address components
      for "111" (the street number), "8th Avenue" (the route), "New
      York" (the city) and "NY" (the US state). These address
      components contain additional information as noted below.

    * `address_components[]` is an array containing the separate
      address components, as explained above. **Note** that
      `address_components[]` may contain more address components than
      noted within the `formatted_address`. Each `address_component`
      typically contains:
      * `types[]` is an array indicating the type of the address
        component.

      * `long_name` is the full text description or name of the address
        component as returned by the Geocoder.

      * `short_name` is an abbreviated textual name for the address
        component, if available. For example, an address component for
        the state of Alaska may have a `long_name` of "Alaska" and a
        `short_name` of "AK" using the 2-letter postal abbreviation.

    * `postcode_localities[]` is an array denoting all the localities
      contained in a postal code. This is only present when the result
      is a postal code that contains multiple localities.

    * `geometry` contains the following information:
      * `location` contains the geocoded latitude,longitude value. For
        normal address lookups, this field is typically the most
        important.

      * `location_type` stores additional data about the specified
        location. The following values are currently supported:
          * "ROOFTOP" indicates that the returned result is a precise
            geocode for which we have location information accurate down
            to street address precision.
          * "RANGE_INTERPOLATED" indicates that the returned result
            reflects an approximation (usually on a road) interpolated
            between two precise points (such as intersections).
            Interpolated results are generally returned when rooftop
            geocodes are unavailable for a street address.
          * "GEOMETRIC_CENTER" indicates that the returned result is the
            geometric center of a result such as a polyline (for example,
            a street) or polygon (region).
          * "APPROXIMATE" indicates that the returned result is
            approximate.
      * `viewport` contains the recommended viewport for displaying the
        returned result, specified as two latitude,longitude values
        defining the southwest and northeast corner of the viewport
        bounding box. Generally the viewport is used to frame a result
        when displaying it to a user.

      * `bounds` (optionally returned) stores the bounding box which
        can fully contain the returned result. Note that these bounds
        may not match the recommended viewport. (For example, San
        Francisco includes the Farallon islands, which are technically
        part of the city, but probably should not be returned in the
        viewport.)

    * `partial_match` indicates that the geocoder did not return an
      exact match for the original request, though it was able to match
      part of the requested address. You may wish to examine the
      original request for misspellings and/or an incomplete address.
      Partial matches most often occur for street addresses that do not
      exist within the locality you pass in the request. Partial
      matches may also be returned when a request matches two or more
      locations in the same locality. For example, "21 Henr St,
      Bristol, UK" will return a partial match for both Henry Street
      and Henrietta Street. Note that if a request includes a
      misspelled address component, the geocoding service may suggest
      an alternative address. Suggestions triggered in this way will
      also be marked as a partial match.

    * `place_id` is a unique identifier that can be used with other
      Google APIs. For example, you can use the place_id in a Google
      Places API request to get details of a local business, such as
      phone number, opening hours, user reviews, and more.

  ## Examples

      # Geocode with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.geocode("1600 Amphitheatre Parkway, Mountain View, CA", key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      iex> {:ok, %{"results" => [result]}} =
      ...>  GoogleMaps.geocode("1600 Amphitheatre Parkway, Mountain View, CA")
      iex> result["formatted_address"]
      "Google Building 41, 1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA"
      iex> result["geometry"]["location"]["lat"]
      37.4224082
      iex> result["geometry"]["location"]["lng"]
      -122.0856086

      iex> {:ok, %{"results" => [result|_]}} =
      ...>  GoogleMaps.geocode({40.714224,-73.961452})
      iex> result["formatted_address"]
      "277 Bedford Ave, Brooklyn, NY 11211, USA"

      iex> {:ok, %{"results" => [result|_]}} =
      ...>  GoogleMaps.geocode("place_id:ChIJd8BlQ2BZwokRAFUEcm_qrcA")
      iex> result["formatted_address"]
      "277 Bedford Ave, Brooklyn, NY 11211, USA"

      iex> {:ok, %{"results" => [result|_]}} =
      ...>  GoogleMaps.geocode({:place_id, "ChIJd8BlQ2BZwokRAFUEcm_qrcA"})
      iex> result["formatted_address"]
      "277 Bedford Ave, Brooklyn, NY 11211, USA"
  """
  @spec geocode(map() | String.t | coordinate() | place_id, options()) :: Response.t()
  def geocode(input, options \\ [])

  # Reverse geo-coding
  def geocode({lat, lng}, options) when is_number(lat) and is_number(lng) do
    params = Keyword.merge(options, [latlng: "#{lat},#{lng}"])
    GoogleMaps.get("geocode", params)
  end

  def geocode({:place_id, place_id}, options) do
    params = Keyword.merge(options, [place_id: place_id])
    GoogleMaps.get("geocode", params)
  end

  def geocode("place_id:" <> place_id, options) do
    params = Keyword.merge(options, [place_id: place_id])
    GoogleMaps.get("geocode", params)
  end
  # Geocode using components.
  def geocode(components, options) when is_map(components) do
    components = Enum.map_join(components, "|", fn({k, v}) -> "#{k}:#{v}" end)
    params = Keyword.merge(options, [components: components])
    GoogleMaps.get("geocode", params)
  end

  def geocode(address, options) when is_binary(address) do
    params = Keyword.merge(options, [address: address])
    GoogleMaps.get("geocode", params)
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
    errors, or `{:error, status, error_message}` when the request is successful, but
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

      # Searching with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.place_autocomplete("Paris France", key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      # Searching for "Paris"
      iex> {:ok, result} = GoogleMaps.place_autocomplete("Paris France")
      iex> Enum.count(result["predictions"]) > 0
      true
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
  @spec place_autocomplete(String.t, options()) :: Response.t()
  def place_autocomplete(input, options \\ []) do
    params = options
    |> Keyword.merge([input: input])

    GoogleMaps.get("place/autocomplete", params)
  end

  @doc """
  Provide a query prediction for text-based geographic searches.

  The Query Autocomplete service allows you to add on-the-fly
  geographic query predictions to your application. Instead of
  searching for a specific location, a user can type in a categorical
  search, such as "pizza near New York" and the service responds with
  a list of suggested queries matching the string. As the Query
  Autocomplete service can match on both full words and substrings,
  applications can send queries as the user types to provide
  on-the-fly predictions.

  ## Args:
    * `input` — The text string on which to search. The Places
      service will return candidate matches based on this
      string and order results based on their perceived relevance.

  ## Options:
    * `offset` — The character position in the input term at which the
      service uses text for predictions. For example, if the input is
      'Googl' and the completion point is 3, the service will match
      on 'Goo'. The `offset` should generally be set to the position of
      the text caret. If no offset is supplied, the service will use
      the entire term.

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
      Places service will attempt to use the native language of the
      domain from which the request is sent.

  ## Returns

    This function returns `{:ok, body}` if the request is successful, and
    Google returns data. The returned body is a map contains two root
    elements:
    * `status` contains metadata on the request.
    * `predictions` contains an array of query predictions.

    Each prediction result contains the following fields:

    * `description` contains the human-readable name for the returned
      result. For `establishment` results, this is usually the business
      name.

    * `terms` contains an array of terms identifying each section of
      the returned description (a section of the description is
      generally terminated with a comma). Each entry in the array has
      a `value` field, containing the text of the term, and an `offset`
      field, defining the start position of this term in the
      description, measured in Unicode characters.

    * `matched_substring` contains an `offset` value and a `length`.
      These describe the location of the entered term in the prediction
      result text, so that the term can be highlighted if desired.

    Note that some of the predictions may be places, and the `place_id`,
    `reference` and `type` fields will be included with those
    predictions. See Place Autocomplete Results for information about
    these results.

  ## Examples

      # A request with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.place_query("Pizza near Par", key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      # A request "Pizza near Par":
      iex> {:ok, result} = GoogleMaps.place_query("Pizza near Par")
      iex> is_list(result["predictions"])
      true

      # A request "Pizza near Par", with results in French:
      iex> {:ok, result} = GoogleMaps.place_query("Pizza near Par", [language: "fr"])
      iex> is_list(result["predictions"])
      true
  """
  @spec place_query(String.t, options()) :: Response.t()
  def place_query(input, options \\ []) do
    params = options
    |> Keyword.merge([input: input])

    GoogleMaps.get("place/queryautocomplete", params)
  end

  @doc """
    Search for nearby places based on location and radius.

    The Google Places API Web Service allows you to query
    for place information on a variety of categories, 
    such as: establishments, prominent points of interest,
    geographic locations, and more. You can search for places
    either by proximity or a text string. A Place Search 
    returns a list of places along with summary information
    about each place; additional information is available
    via a Place Details query


  ## Args:
  * `location` — The latitude/longitude around which to
    retrieve place information. Can be in string format: 
    `"123.456,-123.456"` or tuple format: `{123.456, -123.456}`

  * `radius` — Defines the distance (in meters) within which
    to return place results. The maximum allowed radius is 50 000 meters.
    Note that radius must not be included if `rankby=distance`
    (described under Optional parameters below) is specified


  ## Options:
  * `keyword` — The text string on which to search. The Places
    service will return candidate matches based on this
    string and order results based on their perceived relevance.

  * `language` — The language code, indicating in which language the
    results should be returned, if possible. Searches are also biased
    to the selected language; results in the selected language may be
    given a higher ranking. See the [list of supported languages](https://developers.google.com/maps/faq#languagesupport)
    and their codes. Note that we often update supported languages so
    this list may not be exhaustive. If language is not supplied, the
    Places service will attempt to use the native language of the
    domain from which the request is sent.

  * `minprice` and `maxprice` - Restricts results to only those places 
    within the specified price level. Valid values are in the range 
    from `0` (most affordable) to `4` (most expensive), inclusive. 
    The exact amount indicated by a specific value will vary from 
    region to region.

  * `opennow` - Returns only those places that are open for business at
    the time the query is sent. Places that do not specify opening hours
    in the Google Places database will not be returned if you include
    this parameter in your query.

  * `name` - A term to be matched against all content that Google has indexed for this place.
    Equivalent to keyword. The name field is no longer restricted to place names.
    Values in this field are combined with values in the keyword field and passed
    as part of the same search string. We recommend using only the keyword parameter
    for all search terms.

  * `type` - Restricts the results to places matching the specified type. 
    Only one type may be specified (if more than one type is provided, 
    all types following the first entry are ignored). 
    See the [list of supported types](https://developers.google.com/places/web-service/supported_types).

  * `rankby` - Specifies the order in which results are listed. 
    Note that rankby must not be included if radius(described under Required parameters above) is specified.
    Possible values are:

    * `prominence` - (default). This option sorts results based on their importance.
      Ranking will favor prominent places within the specified area. 
      Prominence can be affected by a place's ranking in Google's index,
      global popularity, and other factors.

    * `distance` - This option biases search results in ascending order by
      their distance from the specified location. When distance is specified,
      one or more of keyword, name, or type is required.

  ## Returns

    This function returns `{:ok, body}` if the request is successful, and
    Google returns data. The returned body is a map that contains four root
    elements:

    * `status` contains metadata on the request.

    * `results` contains an array of nearby places.

    * `html_attributons` contain a set of attributions about this listing which must be displayed to the user.

    * `next_page_token` contains a token that can be used to return up to 20 additional results. 

      A `next_page_token` will not be returned if there are no additional results to display. 
      The maximum number of results that can be returned is 60. There is a short delay between when a 
      `next_page_token` is issued, and when it will become valid.


  Each result contains the following fields:


    * `geometry` contains geometry information about the result, generally including the location (geocode)
      of the place and (optionally) the viewport identifying its general area of coverage.

    * `icon` contains the URL of a recommended icon which may be displayed to the user when indicating this result.

    * `name` contains the human-readable name for the returned result. For establishment results, this is usually the business name.

    * `opening_hours` may contain the following information:

      * `open_now` is a boolean value indicating if the place is open at the current time.

    * `photos[]` - an array of photo objects, each containing a reference to an image.
      A Place Search will return at most one photo object. Performing a Place Details request on the place
      may return up to ten photos. More information about Place Photos and how you can use the images in your
      application can be found in the [Place Photos](https://developers.google.com/places/web-service/photos) documentation.
      A photo object is described as:

      * `photo_reference` — a string used to identify the photo when you perform a Photo request.

      * `height` — the maximum height of the image.

      * `width` — the maximum width of the image.

      * `html_attributions[]` — contains any required attributions. This field will always be present, but may be empty.

    * `place_id` - a textual identifier that uniquely identifies a place. To retrieve information about the place,
      pass this identifier in the placeId field of a Places API request. For more information about place IDs, 
      see the [place ID overview](https://developers.google.com/places/web-service/place-id).

    * `scope` - Indicates the scope of the `place_id`. The possible values are:

      * `APP`: The place ID is recognised by your application only. This is because your application added the place,
        and the place has not yet passed the moderation process.

      * `GOOGLE`: The place ID is available to other applications and on Google Maps.

    * `alt_ids` — An array of zero, one or more alternative place IDs for the place, 
      with a scope related to each alternative ID. Note: This array may be empty or not present. 
      If present, it contains the following fields:

      * `place_id` — The most likely reason for a place to have an alternative place ID is if your application
        adds a place and receives an application-scoped place ID, then later receives a Google-scoped place ID
        after passing the moderation process.

      * `scope` — The scope of an alternative place ID will always be APP, indicating that the alternative
        place ID is recognised by your application only.

    * `price_level` — The price level of the place, on a scale of `0` to `4`. The exact amount indicated by a
      specific value will vary from region to region. Price levels are interpreted as follows:

      * `0` — Free

      * `1` — Inexpensive

      * `2` — Moderate

      * `3` — Expensive

      * `4` — Very Expensive

    * `rating` contains the place's rating, from 1.0 to 5.0, based on aggregated user reviews

    * `types` contains an array of feature types describing the given result. 
      See the [list of supported types](https://developers.google.com/places/web-service/supported_types#table2).

    * `vicinity` contains a feature name of a nearby location. Often this feature refers to a street or
      neighborhood within the given results.

    * `permanently_closed` is a boolean flag indicating whether the place has permanently shut down (value true).
      If the place is not permanently closed, the flag is absent from the response.

  ## Examples

      # Search with an invalid API key
      iex> {:error, status, error_message} = GoogleMaps.place_nearby("38.8990252802915,-77.0351808197085", 500, key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      # Search for museums 500 meters around the White house 
      iex> {:ok, response} = GoogleMaps.place_nearby("38.8990252802915,-77.0351808197085", 500)
      iex> is_list(response["results"])
      true
      
      # Search for museums by the white house but rank by distance
      iex> {:ok, response} = GoogleMaps.place_nearby(
      ...>  "38.8990252802915,-77.0351808197085",
      ...>  500, 
      ...>  [rankby: "distance",
      ...>  keyword: "museum"])
      iex>  Enum.any?(response["results"],
      ...>  fn result -> result["name"] == "National Museum of Women in the Arts" end)
      true
  """
  @spec place_nearby(coordinate(), integer, options()) :: Response.t()
  def place_nearby(location, radius, options \\ [])

  def place_nearby(location, radius, options) when is_binary(location) do
    params =
    if options[:rankby] == "distance" do
      Keyword.merge(options, [location: location])
    else
      Keyword.merge(options, [location: location, radius: radius])
    end
    GoogleMaps.get("place/nearbysearch", params)
  end

  def place_nearby({latitude, longitude}, radius, options) when is_number(latitude) and is_number(longitude) do
    place_nearby("#{latitude},#{longitude}", radius, options)
  end

  @doc """
    A Place Details request returns more comprehensive information about the indicated place
    such as its complete address, phone number, user rating and reviews.

  ## Args:

    * `place_id` — A textual identifier that uniquely identifies a place,
      returned from a [Place Search](https://developers.google.com/places/web-service/search).
      For more information about place IDs, see the [place ID overview](https://developers.google.com/places/web-service/place-id).

      Can be in the following formats:

      * tuple: `{:place_id, "ChIJy5RYvL23t4kR3U1oXsAxEzs"}`

      * place_id string: `"place_id:ChIJy5RYvL23t4kR3U1oXsAxEzs"`

      * string: `"ChIJy5RYvL23t4kR3U1oXsAxEzs"`

  ## Options:

    * `language` — The language code, indicating in which language the
      results should be returned, if possible. Searches are also biased
      to the selected language; results in the selected language may be
      given a higher ranking. See the [list of supported languages](https://developers.google.com/maps/faq#languagesupport)
      and their codes. Note that we often update supported languages so
      this list may not be exhaustive. If language is not supplied, the
      Places service will attempt to use the native language of the
      domain from which the request is sent.

    * `region` — The region code, specified as a [ccTLD](https://en.wikipedia.org/wiki/CcTLD) (country code top-level domain)
      two-character value. Most ccTLD codes are identical to ISO 3166-1 codes,
      with some exceptions. This parameter will only influence, not fully restrict,
      results. If more relevant results exist outside of the specified region,
      they may be included. When this parameter is used, the country name is
      omitted from the resulting `formatted_address` for results in the specified region.
    
  ## Returns
    
    This function returns `{:ok, body}` if the request is successful, and
    Google returns data. The returned body is a map that contains three root
    elements:

    * `status` contains metadata on the request.

    * `result` contains the detailed information about the place requested

    * `html_attributions` contains a set of attributions about this listing which must be displayed to the user.

  Each result contains the following fields:

    * `address_components[]` is an array containing the separate components applicable to this address.
      Each address component typically contains the following fields:

      * `types[]` is an array indicating the type of the address component.

      * `long_name` is the full text description or name of the address component as returned by the Geocoder.
      
      * `short_name` is an abbreviated textual name for the address component, if available.
        For example, an address component for the state of Alaska may have a `long_name` of
        "Alaska" and a `short_name` of "AK" using the 2-letter postal abbreviation.

      Note the following facts about the address_components[] array:

        * The array of address components may contain more components than the `formatted_address.`

        * The array does not necessarily include all the political entities that contain an address,
          apart from those included in the formatted_address. To retrieve all the political entities
          that contain a specific address, you should use reverse geocoding, passing the
          latitude/longitude of the address as a parameter to the request

        * The format of the response is not guaranteed to remain the same between requests.
          In particular, the number of `address_components` varies based on the address requested
          and can change over time for the same address. A component can change position in the array.
          The type of the component can change. A particular component may be missing in a later response.

    * `formatted_address` is a string containing the human-readable address of this place.

      Often this address is equivalent to the postal address. Note that some countries,
      such as the United Kingdom, do not allow distribution of true postal addresses due to licensing restrictions.

      The formatted address is logically composed of one or more address components. For example, the address
      "111 8th Avenue, New York, NY" consists of the following components: "111" (the street number),
      "8th Avenue" (the route), "New York" (the city) and "NY" (the US state).

      Do not parse the formatted address programmatically. Instead you should use the individual address components,
      which the API response includes in addition to the formatted address field

    * `formatted_phone_number` contains the place's phone number in its [local format](http://en.wikipedia.org/wiki/Local_conventions_for_writing_telephone_numbers).
      For example, the `formatted_phone_number` for Google's Sydney, Australia office is `(02) 9374 4000`.

    * `adr_address` is a representation of the place's address in the [adr microformat](http://microformats.org/wiki/adr).

    * `geometry` contains the following information:

      * `location` contains the geocoded latitude,longitude value for this place.

      * `viewport` contains the preferred viewport when displaying this place on a map as a `LatLngBounds` if it is known.

    * `icon` contains the URL of a suggested icon which may be displayed to the user when indicating this result on a map.

    * `international_phone_number` contains the place's phone number in international format.
      International format includes the country code, and is prefixed with the plus (+) sign.
      For example, the `international_phone_number` for Google's Sydney, Australia office is `+61 2 9374 4000`

    * `name` contains the human-readable name for the returned result.
      For `establishment` results, this is usually the canonicalized business name.

    * `opening_hours` contains the following information:

      * `open_now` is a boolean value indicating if the place is open at the current time.

      * `periods[]` is an array of opening periods covering seven days, starting from Sunday, in chronological order.
        Each period contains:

        * `open` contains a pair of day and time objects describing when the place opens:

          * `day` a number from 0–6, corresponding to the days of the week, starting on Sunday. For example, 2 means Tuesday.

          * `time` may contain a time of day in 24-hour hhmm format. Values are in the range 0000–2359. 
            The `time` will be reported in the place’s time zone.

        * `close` may contain a pair of day and time objects describing when the place closes.
          Note: If a place is always open, the close section will be missing from the response.
          Clients can rely on always-open being represented as an open period containing day
          with value 0 and time with value 0000, and no close.

      * `weekday_text` is an array of seven strings representing the formatted opening hours for each day of the week.
        If a language parameter was specified in the Place Details request, the Places Service will format and localize
        the opening hours appropriately for that language. The ordering of the elements in this array depends on the
        language parameter. Some languages start the week on Monday while others start on Sunday.

    * `permanently_closed` is a boolean flag indicating whether the place has permanently shut down (value `true`).
      If the place is not permanently closed, the flag is absent from the response.

    * `photos[]` — an array of photo objects, each containing a reference to an image.
      A Place Details request may return up to ten photos.
      More information about place photos and how you can use the images in your application can be found in the [Place Photos documentation](https://developers.google.com/places/web-service/photos).
      A photo object is described as:

        * `photo_reference` — a string used to identify the photo when you perform a Photo request.

        * `height` — the maximum height of the image.

        * `width` — the maximum width of the image.

        * `html_attributions[]` — contains any required attributions. This field will always be present, but may be empty.

    * `place_id`: A textual identifier that uniquely identifies a place. To retrieve information about the place, pass this
    identifier in the placeId field of a Places API request. For more information about place IDs, see the [place ID overview](https://developers.google.com/places/web-service/place-id).

    * `scope`: Indicates the scope of the place_id. The possible values are:

      * `APP`: The place ID is recognised by your application only. This is because your application added the place,
        and the place has not yet passed the moderation process.

      * `GOOGLE`: The place ID is available to other applications and on Google Maps.

    * `alt_ids` — An array of zero, one or more alternative place IDs for the place, with a scope related to each alternative ID.
      Note: This array may be empty or not present. If present, it contains the following fields:

      * `place_id` — The most likely reason for a place to have an alternative place ID is if your application
        adds a place and receives an application-scoped place ID, then later receives a Google-scoped place
        ID after passing the moderation process.

      * `scope` — The scope of an alternative place ID will always be APP, indicating that the alternative
        place ID is recognised by your application only.

    * `price_level` — The price level of the place, on a scale of `0` to `4`.
      The exact amount indicated by a specific value will vary from region to region.
      Price levels are interpreted as follows:

      * `0` — Free

      * `1` — Inexpensive

      * `2` — Moderate

      * `3` — Expensive

      * `4` — Very Expensive

    * `rating` contains the place's rating, from 1.0 to 5.0, based on aggregated user reviews.

    * `reviews[]` a JSON array of up to five reviews. If a language parameter was specified in
      the Place Details request, the Places Service will bias the results to prefer reviews written in that language.
      Each review consists of several components:

      * `aspects` contains a collection of AspectRating objects, each of which provides a rating of a
        single attribute of the establishment. The first object in the collection is considered the primary aspect.
        Each AspectRating is described as:

        * `type` the name of the aspect that is being rated.
          The following types are supported: `appeal`, `atmosphere`, `decor`, `facilities`, `food`, `overall`, `quality` and `service`.

        * `rating` the user's rating for this particular aspect, from 0 to 3.

      * `author_name` the name of the user who submitted the review. Anonymous reviews are attributed to "A Google user".

      * `author_url` the URL to the user's Google Maps Local Guides profile, if available.

      * `language` an IETF language code indicating the language used in the user's review. This field contains the main
        language tag only, and not the secondary tag indicating country or region. For example, all the English reviews
        are tagged as 'en', and not 'en-AU' or 'en-UK' and so on.

      * `rating` the user's overall rating for this place. This is a whole number, ranging from 1 to 5.

      * `text` the user's review. When reviewing a location with Google Places, text reviews are considered optional.
        Therefore, this field may by empty. Note that this field may include simple HTML markup.
        For example, the entity reference `&amp;` may represent an ampersand character.

      * `time` the time that the review was submitted, measured in the number of seconds since since midnight, January 1, 1970 UTC.

    * `types[]` contains an array of feature types describing the given result. See the [list of supported types](https://developers.google.com/places/web-service/supported_types#table2).

    * `url` contains the URL of the official Google page for this place. This will be the Google-owned page that contains the
      best available information about the place. Applications must link to or embed this page on any screen that shows
      detailed results about the place to the user.

    * `utc_offset` contains the number of minutes this place’s current timezone is offset from UTC.
      For example, for places in Sydney, Australia during daylight saving time this would be 660 (+11 hours from UTC),
      and for places in California outside of daylight saving time this would be -480 (-8 hours from UTC).

    * `vicinity` lists a simplified address for the place, including the street name, street number, and locality,
      but not the province/state, postal code, or country. For example, Google's Sydney,
      Australia office has a vicinity value of 48 Pirrama Road, Pyrmont.

    * `website` lists the authoritative website for this place, such as a business' homepage.

  ## Examples

      iex> {:error, status, error_message} = GoogleMaps.place_details({:place_id, "ChIJy5RYvL23t4kR3U1oXsAxEzs"}, key: "invalid key")
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      iex> {:ok, response} = GoogleMaps.place_details({:place_id, "ChIJy5RYvL23t4kR3U1oXsAxEzs"})
      iex> is_map(response["result"])
      true

      iex> {:ok, response} = GoogleMaps.place_details("place_id:ChIJy5RYvL23t4kR3U1oXsAxEzs")
      iex> response["result"]["name"]
      "719-751 Madison Pl NW"

      iex> {:ok, response} = GoogleMaps.place_details("ChIJy5RYvL23t4kR3U1oXsAxEzs")
      iex> response["result"]["formatted_address"]
      "719-751 Madison Pl NW, Washington, DC 20005, USA"
  """
  @spec place_details(place_id, options()) :: Response.t()
  def place_details(place_id, options \\ [])

  def place_details({:place_id, place_id}, options) do
    params =
    options
    |> Keyword.merge([place_id: place_id])
    GoogleMaps.get("place/details", params)
  end

  def place_details("place_id:" <> place_id, options) do
    place_details({:place_id, place_id}, options)
  end

  def place_details(place_id, options) do
    place_details({:place_id, place_id}, options)
  end


  @doc """
    A Timezone request returns timezone information for the given location.

  ## Args:

    * `location` - A comma-separated latitude / longitude tuple (eg, location = -33.86,151.20),
      which represents the location to be searched.
    * `timestamp` - Specifies the desired time in seconds after midnight, UTC,
      from January 1, 1970. Google Maps Time Zone API uses timestamp to determine
      if summer time should be applied. The hours before 1970 can be expressed as negative values.

  ## Options:

    * `language` — The language code, indicating in which language the
      results should be returned, if possible. Searches are also biased
      to the selected language; results in the selected language may be
      given a higher ranking. See the [list of supported languages](https://developers.google.com/maps/faq#languagesupport)
      and their codes. Note that we often update supported languages so
      this list may not be exhaustive. If language is not supplied, the
      Places service will attempt to use the native language of the
      domain from which the request is sent.

  ## Returns

    This function returns `{:ok, body}` if the request is successful, and
    Google returns data. It returns either `{:error, status}` or `{:error, status, error_message}`
    when there is an error, depending if there's an error message or not.
    The returned body is a map that contains four root elements:

    * `dstOffset` The time difference for summer time in seconds.
      This value will be zero if the time zone is not in daylight saving time
      during the specified timestamp.

    * `rawOffset` The time difference with respect to UTC (in seconds)
      for the determined location. This does not consider summer timetables.

    * `timeZoneId` A string that contains the id. of "tz" in the time zone,
      such as "United States / Los_Angeles" or "Australia / Sydney"

    * `timeZoneName` A string that contains the name in long format the
      time zone This field will be located if the parameter is configured of
      language; p. eg, "Pacific Summer Time" or "Summer Time from Eastern Australia".

    * `status` contains metadata on the request.

  ## Examples

      iex> {:ok, response} = GoogleMaps.timezone({8.6069305,104.7196242})
      iex> is_map(response)
      true

      iex> {:ok, response} = GoogleMaps.timezone({8.6069305,104.7196242})
      iex> response["timeZoneId"]
      "Asia/Saigon"
  """
  @spec timezone(coordinate(), options()) :: Response.t()
  def timezone(input, options \\ [])

  def timezone(location, options) when is_binary(location) do
    params = Keyword.merge(options, [location: location, timestamp: :os.system_time(:seconds)])
    GoogleMaps.get("timezone", params)
  end

  def timezone({lat, lng}, options) when is_number(lat) and is_number(lng) do
    timezone("#{lat},#{lng}", options)
  end

  @doc """
  Direct request to Google Maps API endpoint.

  Instead of relying on the functionality this module provides, you can
  use this function to make direct request to the Google Maps API.

  It takes an endpoint string, and a keyword list of parameters.

  ## Examples

      iex> {:error, status, error_message} = GoogleMaps.get("directions", [
      ...>   origin: "Disneyland",
      ...>   destination: "Universal Studios Hollywood",
      ...>   key: "invalid key",
      ...> ])
      iex> status
      "REQUEST_DENIED"
      iex> error_message
      "The provided API key is invalid."

      iex> {:ok, result} = GoogleMaps.get("directions", [
      ...>   origin: "Disneyland",
      ...>   destination: "Universal Studios Hollywood"
      ...> ])
      iex> [route] = result["routes"]
      iex> route["bounds"]
      %{"northeast" => %{"lat" => 34.1373841, "lng" => -117.9220826},
       "southwest" => %{"lat" => 33.8151707, "lng" => -118.3575456}}

      iex> {:ok, result} = GoogleMaps.get("place/autocomplete", [input: "Paris, France"])
      iex> Enum.count(result["predictions"]) > 0
      true
      iex> [paris | _rest] = result["predictions"]
      iex> paris["description"]
      "Paris, France"
      iex> paris["place_id"]
      "ChIJD7fiBh9u5kcRYJSMaMOCCwQ"
      iex> paris["types"]
      [ "locality", "political", "geocode" ]

      # A request "Pizza near Par":
      iex> {:ok, result} = GoogleMaps.get("place/queryautocomplete", [input: "Pizza near Par"])
      iex> is_list(result["predictions"])
      true
  """
  @spec get(String.t, options()) :: Response.t()
  def get(endpoint, params) do
    Request.get(endpoint, params)
    |> Response.wrap
  end
end
