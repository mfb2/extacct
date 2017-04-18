defmodule Extacct.API do
  import Extacct.EnvironmentHelper

  alias Extacct.API.MessageBuilder
  alias Extacct.API.GatewayResponse
  alias Extacct.API.GatewayResponse.Headers

  @max_list_size "100"
  @all_fields "*"

  def get_list(object) do
    get_list(object, @max_list_size)
  end
  def get_list(object, max_list_size) do
    MessageBuilder.get_list(object, max_list_size)
    |> gateway.process(:get_list)
    |> create_response(:get_list)
  end
  def get_list(object, start, max_list_size) do
    MessageBuilder.get_list(object, start, max_list_size)
    |> gateway.process(:get_list)
    |> create_response(:get_list)
  end

  def read(object, keys, fields \\ @all_fields) do
    MessageBuilder.read(object, keys, fields)
    |> gateway.process(:read)
    |> create_response(:read)
  end

  def read_by_name(object, keys, fields \\ @all_fields) do
    MessageBuilder.read_by_name(object, keys, fields)
    |> gateway.process(:read_by_name)
    |> create_response(:read_by_name)
  end

  def read_by_query(object, query, fields \\ @all_fields) do
    MessageBuilder.read_by_query(object, query, fields)
    |> gateway.process(:read_by_query)
    |> create_response(:read_by_query)
  end

  def read_report(report_name) do
    MessageBuilder.read_report(report_name)
    |> gateway.process(:read_report)
    |> create_response(:read_report)
  end

  def read_more(method, identifier) do
    MessageBuilder.read_more(method, identifier)
    |> gateway.process(:read_more)
    |> create_response(:read_more)
  end

  def inspect_detail(object) do
    MessageBuilder.inspect_detail(object)
    |> gateway.process(:inspect_detail)
    |> create_response(:inspect_detail)
  end

  defp gateway, do: env_var(:gateway)

  defp create_response(%GatewayResponse{headers: headers, content: response}, request_type) do
    {request_type, headers.control_id, metadata(headers), response}
  end

  defp metadata(%Headers{} = headers) do
    Map.from_struct(headers)
    |> Map.drop([:control_id])
  end

end
