defmodule Extacct.RequestWorker do
  use GenServer
  alias Extacct.API
  import Extacct.EnvironmentHelper
  require Logger

  #############################################################################
  # Client API
  #############################################################################

  def read_by_query(object, query, fields, handler), do:
    start([request: {:read_by_query, object, query, fields}, response_handler: handler])

  def read_report(report_name, handler), do:
    start([request: {:read_report, report_name}, response_handler: handler])

  def get_list(object, handler), do:
    start([request: {:get_list, object}, response_handler: handler])

  #############################################################################
  # Server API
  #############################################################################

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  def init([request: {:read_by_query, object, query, fields}, response_handler: handler]) do
    Logger.debug ":init :read_by_query"
    send(self(), {:run_read_by_query, object, query, fields})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:read_report, report_name}, response_handler: handler]) do
    Logger.debug ":init :read_report"
    send(self(), {:generate_report, report_name})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:get_list, object}, response_handler: handler]) do
    Logger.debug ":init :get_list"
    send(self(), {:generate_list, object})
    {:ok, [response_handler: handler]}
  end

  def handle_info({:run_read_by_query, object, query, fields}, [response_handler: handler] = state) do
    Logger.debug ":run_read_by_query #{inspect object}, query: #{inspect query}"

    case API.read_by_query(object, query, fields) do
      {:read_by_query, _control_id, %{status: :success, records_remaining: 0} = metadata, result} ->
        Logger.debug ":run_read_by_query completed; metadata: #{inspect metadata}"
        send_to_handler(handler, :query_results, result)
        send_to_handler(handler, :query_end, object)
        {:stop, :normal, state}
      {:read_by_query, _control_id, %{status: :success, result_id: result_id} = metadata, result} ->
        Logger.debug ":run_read_by_query received results; metadata: #{inspect metadata}"
        send_to_handler(handler, :query_results, result)
        send(self(), {:check_read_by_query, result_id})
        {:noreply, state}
      {:read_by_query, _control_id, _metadata, unexpected_result} ->
        Logger.error ":run_read_by_query encountered an error: #{inspect unexpected_result}"
        send_to_handler(handler, :query_error, unexpected_result)
        {:stop, unexpected_result, state}
    end
  end

  def handle_info({:check_read_by_query, result_id}, [response_handler: handler] = state) do
    Logger.debug ":check_read_by_query for result_id #{inspect result_id}"
    case API.read_more(:resultId, result_id) do
      {:read_more, _control_id, %{result_id: result_id, records_remaining: records_remaining} = _metadata, result} ->
        Logger.debug ":check_read_by_query for result_id #{result_id} returned data"
        send_to_handler(handler, :query_results, result)
        if records_remaining > 0 do
          Logger.debug "calling :check_read_by_query for result_id #{result_id} for more data"
          send(self(), {:check_read_by_query, result_id})
          {:noreply, state}
        else
          Logger.debug ":check_read_by_query for result_id #{result_id} has exhaused all records, halting process"
          send_to_handler(handler, :query_end, result_id)
          {:stop, :normal, state}
        end
      {:read_more, _control_id, _metadata, [error: unexpected_result]} ->
        Logger.debug ":check_read_by_query for result_id #{result_id} halting; received: #{inspect unexpected_result}"
        send_to_handler(handler, :query_error, unexpected_result)
        {:stop, unexpected_result, state}
    end

  end

  def handle_info({:generate_report, report_name}, [response_handler: handler] = state) do
    Logger.debug ":generate_report #{inspect report_name}"

    case API.read_report(report_name) do
      {:read_report, _control_id, _metadata, [report_results: [reportid: report_id, status: _status]]} ->
        Logger.debug ":generate_report #{inspect report_name}"
        send_check_report_message(report_id)
        {:noreply, state}
      {:read_report, _control_id, _metadata, unexpected_result} ->
        message = ":generate_report failed!  received: #{inspect unexpected_result}"
        Logger.error message
        send_to_handler(handler, :report_error, message)
        {:stop, message, state}
    end
  end
  def handle_info({:check_report, report_id}, [response_handler: handler] = state) do
    Logger.debug ":check_report #{inspect report_id}"

    case API.read_more(:reportId, report_id) do
      {:read_more, _control_id, _metadata, [report: data]} ->
        Logger.debug ":read_more data received: #{inspect data}"
        send_to_handler(handler, :report_results, data)
        send_check_report_message(report_id)
        {:noreply, state}
      {:read_more, _control_id, _metadata, unexpected_result} ->
        Logger.warn ":check_report halted; received: #{inspect unexpected_result}"
        send_to_handler(handler, :report_end, report_id)
        {:stop, :normal, []}
    end
  end
  def handle_info({:generate_list, object}, [response_handler: handler] = state) do
    Logger.debug ":generate_list #{inspect object}"

    case API.get_list(object, get_list_size()) do
      {:get_list, _control_id, %{status: :success} = metadata, data} ->
        Logger.debug ":get_list data received: #{inspect data}"
        send_to_handler(handler, :get_list_results, data)
        send_check_get_list(object, metadata, state)
      {:get_list, _control_id, _metadata, unexpected_result} ->
        Logger.warn ":generate_list halted; received: #{inspect unexpected_result}"
        send_to_handler(handler, :get_list_error, object)
        halt_check_get_list(object, :get_list_error, handler, state, unexpected_result)
    end
  end
  def handle_info({:check_get_list, object, metadata}, [response_handler: handler] = state) do
    Logger.debug """
      handle_info::check_get_list #{inspect object},
        total: #{metadata.total},
        last_record: #{metadata.last_record},
        first_record: #{metadata.first_record}
      """

    start_record = metadata.last_record + 1
    case API.get_list(object, start_record, get_list_size()) do
      {:get_list, _control_id, %{status: :success} = metadata, data} ->
        Logger.debug ":get_list data received: #{inspect data}"

        send_to_handler(handler, :get_list_results, data)
        check_get_list(object, metadata, state)

      {:get_list, _control_id, _metadata, unexpected_result} ->
        Logger.error ":check_get_list halted; received: #{inspect unexpected_result}"
        halt_check_get_list(object, :get_list_error, handler, state, unexpected_result)
    end
  end

  @spec send_check_report_message(String.t) :: any
  defp send_check_report_message(report_id) do
    Process.send_after(self(), {:check_report, report_id}, read_more_wait_time())
    Logger.debug "sent :check_report message for report_id: #{report_id}"
  end

  @spec check_get_list(String.t, struct, list) :: {:noreply, list} | {:stop, :normal, list} | {:stop, any, list}
  defp check_get_list(object, metadata, [response_handler: handler] = state) do

    next_record = metadata.last_record + 1
    cond do
      next_record <  metadata.total -> send_check_get_list(object, metadata, state)
      next_record >= metadata.total -> halt_check_get_list(object, :get_list_end, handler, state)
    end
  end

  @spec send_check_get_list(String.t, map, list) :: {:noreply, list}
  defp send_check_get_list(object, metadata, state) do
    Process.send_after(self(), {:check_get_list, object, metadata}, read_more_wait_time())
    Logger.debug "sent :check_get_list message for object: #{object}"
    {:noreply, state}
  end

  @spec halt_check_get_list(String.t, :get_list_end | :get_list_error, pid, any, any) :: {:stop, :normal | any, list}
  defp halt_check_get_list(object, status, handler, state, message \\ "") do
    Logger.debug "Halting Extacct.RequestWorker for #{object}"
    send_to_handler(handler, status, message)
    case status do
      :get_list_end   -> {:stop, :normal, state}
      :get_list_error -> {:stop, message, state}
    end
  end

  @spec send_to_handler(pid, atom, any) :: any
  defp send_to_handler(handler, message_type, message_payload) do
    send(handler, {message_type, message_payload})
  end

  defp get_list_size,       do: env_var(:get_list_size)
  defp read_more_wait_time, do: env_var(:read_more_wait_time)
end
