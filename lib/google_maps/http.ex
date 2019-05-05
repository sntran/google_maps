defmodule GoogleMaps.HTTP do
  use GenServer

  require Logger

  defstruct [:conn, requests: %{}, options: []]

  # Stars a connection process to a host.
  def start_link({scheme, host, port, options}) do
    GenServer.start_link(__MODULE__, {scheme, host, port, options})
  end

  @doc """
  Starts a GET connection to a URL.

  Spawns a `GenServer` process to connect to the host, and performs
  the request. If there is an error making the connection, the process
  will stop with the error as reason.
  """
  @callback get(String.t(), Keyword.t(), Keyword.t()) :: {:ok, nil} | {:error, any()}
  def get(url, headers, options \\ []) do
    Process.flag :trap_exit, true

    %{
      scheme: scheme, host: host, port: port,
      path: path, query: query
    } = URI.parse(url)

    result = with {:ok, pid} <- start_link({scheme, host, port, options})
    do
      request(pid, "GET", "#{path}?#{query}", headers, "")
    else
      {:error, error} ->
        {:error, Exception.message(error)}
    end
    Process.flag :trap_exit, false
    result
  end

  @doc """
  Tells a connection process to perform a request to a path.
  """
  def request(pid, method, path, headers, body)
  when is_pid(pid) and method in ["GET", "POST"] and is_binary(path)
  do
    GenServer.call(pid, {:request, method, path, headers, body})
  end

  ## GenServer callbacks

  @impl true
  def init({scheme, host, port, options}) when is_binary(scheme) do
    init({String.to_existing_atom(scheme), host, port, options})
  end
  def init({scheme, host, port, options}) when is_atom(scheme) do
    {transport_opts, options} = Keyword.pop(options, :transport_opts, [])
    {timeout, options} = Keyword.pop(options, :timeout)
    transport_opts = if timeout, do: Keyword.put(transport_opts, :timeout, timeout), else: transport_opts

    with {:ok, conn} <- Mint.HTTP.connect(scheme, host, port, transport_opts: transport_opts)
    do
      state = %__MODULE__{conn: conn, options: options}
      {:ok, state}
    else
      {:error, error} ->
        {:stop, error}
    end
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    # In both the successful case and the error case, we make sure to update the connection
    # struct in the state since the connection is an immutable data structure.
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = put_in(state.conn, conn)
        # We store the caller this request belongs to and an empty map as the response.
        # The map will be filled with status code, headers, and so on.
        request = %{from: from, headers: headers, response: %{}}
        state = put_in(state.requests[request_ref], request)
        {:noreply, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)
        {:noreply, state}

      {:error, conn, reason, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)
        {:reply, {:error, reason}, state}
    end
  end

  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status_code], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], Enum.into(headers, %{}))
  end

  defp process_response({:data, request_ref, data}, state) do
    update_in(state.requests[request_ref].response[:body], fn body -> (body || "") <> data end)
  end

  # When the request is done, we use GenServer.reply/2 to reply to the caller that was
  # blocked waiting on this request.
  defp process_response({:done, request_ref}, state) do
    {request, state} = pop_in(state.requests[request_ref])
    %{response: response, from: from, headers: headers} = request

    case response.status_code do
      200 ->
        GenServer.reply(from, {:ok, response})
      # On a redirect, spawn a new request to that location, waiting and forwarding
      # the result to the original caller.
      302 ->
        result = if state.options[:follow_redirect]
        do
          location = response.headers["location"]
          __MODULE__.get(location, headers)
        else
          {:ok, response}
        end
        GenServer.reply(from, result)
      status_code ->
        GenServer.reply(from, {:error, status_code})
    end

    state
  end
end
