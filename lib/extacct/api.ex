defmodule Extacct.API do
  import Extacct.EnvironmentHelper
  alias Extacct.API.MessageBuilder

  @max_list_size "100"
  @all_fields "*"

  def read(object, keys, fields \\ @all_fields) do
    MessageBuilder.read(object, keys, fields)
    |> process_request(:read)
  end

  def read_by_name(object, keys, fields \\ @all_fields) do
    MessageBuilder.read_by_name(object, keys, fields)
    |> process_request(:readByName)
  end

  def read_by_query(object, query, fields \\ @all_fields) do
    MessageBuilder.read_by_query(object, query, fields)
    |> process_request(:readByQuery)
  end

  def read_report(report_name) do
    MessageBuilder.read_report(report_name)
    |> process_request(:readReport)
  end

  def read_more(method, identifier) do
    MessageBuilder.read_more(method, identifier)
    |> process_request(:readMore)
  end

  defp process_request(request, request_type) do
    request
    |> gateway.process(request_type)
  end

  defp gateway, do: env_var(:gateway)

end
