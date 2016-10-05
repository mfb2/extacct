defmodule Extacct.RequestWorker do
  use GenServer
  require Logger
  import Extacct.EnvironmentHelper

  alias Extacct.API

  #############################################################################
  # Client API
  #############################################################################

  def read(object, keys, fields, handler),           do: start([request: {:read, object, keys, fields}, response_handler: handler])
  def read_by_name(object, keys, fields, handler),   do: start([request: {:read_by_name, object, keys, fields}, response_handler: handler])
  def read_by_query(object, query, fields, handler), do: start([request: {:read_by_query, object, query, fields}, response_handler: handler])
  def read_report(report_name, handler),             do: start([request: {:read_report, report_name}, response_handler: handler])

  #############################################################################
  # Server API
  #############################################################################

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  def init([request: {:read, object, keys, fields}, response_handler: handler]) do
    Logger.debug ":init :read"
    send(self, {:read, object, keys, fields})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:read_by_name, object, keys, fields}, response_handler: handler]) do
    Logger.debug ":init :read_by_name"
    send(self, {:read_by_name, object, keys, fields})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:read_by_query, object, keys, fields}, response_handler: handler]) do
    Logger.debug ":init :read_by_query"
    send(self, {:read_by_query, object, keys, fields})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:read_report, report_name}, response_handler: handler]) do
    Logger.debug ":init :read_report"
    send(self, {:generate_report, report_name})
    {:ok, [response_handler: handler]}
  end

  def handle_info({:read, object, keys, fields}, [response_handler: handler] = state) do
    Logger.debug ":handle_info :read, object: #{inspect object}, keys: #{inspect keys}, fields: #{inspect fields}"
    {_status, data} = API.read(object, keys, fields)

    send_to_handler(handler, :read, data)
    # TODO: Remove this comment!
    # send(self, {status, data})

    {:noreply, state}
  end
  def handle_info({:read_by_name, object, keys, fields}, [response_handler: handler] = state) do
    Logger.debug ":handle_info :read_by_name, object: #{inspect object}, keys: #{inspect keys}, fields: #{inspect fields}"
    {_status, data} = API.read_by_name(object, keys, fields)

    send_to_handler(handler, :read_by_name, data)
    # TODO: Remove this comment!
    # send(self, {status, data})

    {:noreply, state}
  end
  def handle_info({:read_by_query, object, query, fields}, [response_handler: handler] = state) do
    Logger.debug ":handle_info :read_by_query, object: #{inspect object}, query: #{inspect query}, fields: #{inspect fields}"
    {_status, data} = API.read_by_query(object, query, fields)

    send_to_handler(handler, :read_by_query, data)
    # TODO: Remove this comment!
    # send(self, {status, data})

    {:noreply, state}
  end
  def handle_info({:generate_report, report_name}, [response_handler: handler] = state) do
    Logger.debug ":generate_report #{inspect report_name}"
    case API.read_report(report_name) do
      {:read_report, [report_results: [reportid: report_id, status: _status]]} ->
        Logger.debug ":generate_report #{inspect report_name}"
        send_check_report_message(report_id)
        {:noreply, state}
      unexpected_result ->
        message = ":generate_report failed!  received: #{inspect unexpected_result}"
        Logger.error message
        send_to_handler(handler, :report_error, message)
        {:stop, message, []}
    end
  end
  def handle_info({:check_report, report_id}, [response_handler: handler] = state) do
    Logger.debug ":check_report #{inspect report_id}"
    case API.read_more(:reportId, report_id) do
      {:read_more, [report: data]} ->
        Logger.debug ":read_more data received: #{inspect data}"
        send_to_handler(handler, :report_results, data)
        send_check_report_message(report_id)
        {:noreply, state}
      {:read_more, unexpected_result} ->
        Logger.warn ":check_report halted; received: #{inspect unexpected_result}"
        send_to_handler(handler, :report_end, report_id)
        {:stop, :normal, []}
    end
  end

  defp send_to_handler(handler, message_type, message_payload) do
    send(handler, {message_type, message_payload})
  end

  defp send_check_report_message(report_id) do
    Process.send_after(self, {:check_report, report_id}, read_more_wait_time)
    Logger.debug "sent :check_report message for report_id: #{report_id}"
  end

  defp read_more_wait_time, do: env_var(:read_more_wait_time)
end
