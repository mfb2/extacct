defmodule Extacct.API do
  import Extacct.EnvironmentHelper
  alias Extacct.API.MessageBuilder

  @max_list_size "100"
  @all_fields "*"

  def get_list(object) do
    get_list(object, @max_list_size)
  end
  def get_list(object, max_list_size) do
    MessageBuilder.get_list(object, max_list_size)
    |> process_request(:get_list)
  end
  def get_list(object, start, max_list_size) do
    MessageBuilder.get_list(object, start, max_list_size)
    |> process_request(:get_list)
  end
  def read(object, keys, fields \\ @all_fields) do
    MessageBuilder.read(object, keys, fields)
    |> process_request(:read)
  end

  def read_by_name(object, keys, fields \\ @all_fields) do
    MessageBuilder.read_by_name(object, keys, fields)
    |> process_request(:read_by_name)
  end

  def read_by_query(object, query, fields \\ @all_fields) do
    MessageBuilder.read_by_query(object, query, fields)
    |> process_request(:read_by_query)
  end

  def read_report(report_name) do
    MessageBuilder.read_report(report_name)
    |> process_request(:read_report)
  end

  def read_more(method, identifier) do
    MessageBuilder.read_more(method, identifier)
    |> process_request(:read_more)
  end

  defp process_request(request, request_type) do
    request
    |> gateway.process(request_type)
    |> build_response(request_type)
  end

  defp gateway, do: env_var(:gateway)

  defp build_response(response, request_type), do: {request_type, response}

end
