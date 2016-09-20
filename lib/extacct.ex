defmodule Extacct do
  import Extacct.EnvironmentHelper

  alias Extacct.MessageBuilder
  alias Extacct.FunctionBuilder
  alias Extacct.ResponseHandler

  @control_id "testFunctionId"
  @all_fields "*"

  def read(object, keys),        do: read(object, @all_fields, keys)
  def read(object, fields, keys) do
    FunctionBuilder.read(object, fields, keys, @control_id)
    |> process_request
  end

  def read_by_name(object, keys),        do: read_by_name(object, @all_fields, keys)
  def read_by_name(object, fields, keys) do
    FunctionBuilder.read_by_name(object, fields, keys, @control_id)
    |> process_request
  end

  def read_by_query(object, query),        do: read_by_query(object, @all_fields, query)
  def read_by_query(object, fields, query) do
    FunctionBuilder.read_by_query(object, fields, query, @control_id)
    |> process_request
  end

  def read_report(report_name) do
    FunctionBuilder.read_report(report_name, false, @control_id)
    |> process_request
  end

  @doc """

  Reads more data from Intacct.

  method can be three different values:
    :object
    :resultId
    :reportId

  """
  def read_more(method, identifier) do
    FunctionBuilder.read_more(method, identifier, @control_id)
    |> process_request
  end

  defp process_request(functions) do
    functions
    |> MessageBuilder.request(@control_id)
    |> XmlBuilder.generate
    |> gateway.send_request
    |> ResponseHandler.parse
  end

  defp gateway, do: env_var(:gateway)
end
