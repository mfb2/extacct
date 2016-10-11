defmodule Extacct.RequestWorker do
  use GenServer
  require Logger
  import Extacct.EnvironmentHelper

  alias Extacct.API

  #############################################################################
  # Client API
  #############################################################################

  def read_report(report_name, handler), do: start([request: {:read_report, report_name}, response_handler: handler])
  def get_list(object, handler),         do: start([request: {:get_list, object},         response_handler: handler])

  #############################################################################
  # Server API
  #############################################################################

  def start(state) do
    GenServer.start(__MODULE__, state)
  end

  def init([request: {:read_report, report_name}, response_handler: handler]) do
    Logger.debug ":init :read_report"
    send(self, {:generate_report, report_name})
    {:ok, [response_handler: handler]}
  end
  def init([request: {:get_list, object}, response_handler: handler]) do
    Logger.debug ":init :get_list"
    send(self, {:generate_list, object})
    {:ok, [response_handler: handler]}
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
  def handle_info({:generate_list, object}, [response_handler: handler] = state) do
    Logger.debug ":generate_list #{inspect object}"
    case API.get_list(object, get_list_size) do
      {:get_list, [record_metadata: record_metadata, records: data]} ->
        Logger.debug ":get_list data received: #{inspect data}"
        send_to_handler(handler, :get_list_results, data)
        send_check_get_list(object, record_metadata)
        {:noreply, state}
      {:get_list, unexpected_result} ->
        Logger.warn ":check_report halted; received: #{inspect unexpected_result}"
        send_to_handler(handler, :get_list_error, object)
        {:stop, :normal, []}
    end
  end
  def handle_info({:check_get_list,
                  object,
                  [record_metadata: [total: total, last_record: last_record, first_record: first_record]]},
                  [response_handler: handler] = state) do
    Logger.debug ":check_get_list #{inspect object}, total: #{total}, last_record: #{last_record}, first_record: #{first_record} "

    start_record = last_record + 1
    case API.get_list(object, start_record, get_list_size) do
      {:get_list, [record_metadata: record_metadata, records: data]} ->
        Logger.debug ":get_list data received: #{inspect data}"

        send_to_handler(handler, :get_list_results, data)
        next_record = case Keyword.get(record_metadata, :last_record) do
          nil   -> raise CaseClauseError, "Expected :last_record, got nil"
          value -> value + 1
        end

        cond do
          next_record < total ->
            send_check_get_list(object, record_metadata)
            {:noreply, state}
          next_record >= total ->
            halt_check_get_list(object, :get_list_end, handler)
        end
      {:get_list, unexpected_result} ->
        Logger.warn ":check_get_list halted; received: #{inspect unexpected_result}"
        halt_check_get_list(object, :get_list_error, handler)
    end
  end

  defp send_to_handler(handler, message_type, message_payload) do
    send(handler, {message_type, message_payload})
  end

  defp send_check_report_message(report_id) do
    Process.send_after(self, {:check_report, report_id}, read_more_wait_time)
    Logger.debug "sent :check_report message for report_id: #{report_id}"
  end

  defp send_check_get_list(object, record_metadata) do
    Process.send_after(self, {:check_get_list, object, [record_metadata: record_metadata]}, read_more_wait_time)
    Logger.debug "sent :check_get_list message for object: #{object}"
  end

  defp halt_check_get_list(object, status, handler) do
    send_to_handler(handler, status, object)
    {:stop, :normal, []}
  end

  defp get_list_size,       do: env_var(:get_list_size)
  defp read_more_wait_time, do: env_var(:read_more_wait_time)
end
