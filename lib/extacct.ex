defmodule Extacct do
  import Extacct.EnvironmentHelper

  alias Extacct.MessageBuilder
  alias Extacct.FunctionBuilder
  alias Extacct.ResponseHandler

  @control_id "testFunctionId"

  def read_report(report_name) do
    FunctionBuilder.read_report(report_name, false, @control_id)
    |> MessageBuilder.request(@control_id)
    |> XmlBuilder.generate
    |> gateway.send_request
    |> ResponseHandler.parse
  end

  def read_more(report_id) do
    FunctionBuilder.read_more(report_id, @control_id)
    |> MessageBuilder.request(@control_id)
    |> XmlBuilder.generate
    |> gateway.send_request
    |> ResponseHandler.parse
  end

  defp gateway, do: env_var(:gateway)
end
