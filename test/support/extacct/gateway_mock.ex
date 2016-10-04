defmodule Extacct.API.GatewayMock do

  @results_report_id   "abc123"
  @completed_report_id "xyz789"
  @pending_status      "PENDING"

  def process(xml, :read_report) do
    cond do
      xml =~ "GenServer Test Report Results" -> [report: report_status(:results)]
      xml =~ "GenServer Test Report End"     -> [report: report_status(:completed)]
      xml =~ "Rando Report"                  -> {:report_submitted, report_id: "random_string"}
      xml =~ "Broken Report"                 -> {:error, "Invalid Report"}
    end
  end
  def process(xml, :read_more) do
    cond do
      xml =~ @results_report_id ->
        generate_report_contents(:xml)
      xml =~ @completed_report_id ->
        generate_report_error(:xml)
      true ->
        generate_report_contents(:json)
    end
  end
  def process(_xml, :read_by_name),  do: object_map
  def process(_xml, :read_by_query), do: object_map
  def process(_xml, :read),          do: object_map

  defp report_status(:results),   do: [reportid: @results_report_id,   status: @pending_status]
  defp report_status(:completed), do: [reportid: @completed_report_id, status: @pending_status]

  defp object_map, do:
    %{
      "ENTRY_DATE" => "09/16/2016",
      "RECORDNO" => "1000"
    }
  defp generate_report_contents(:json), do:
    %{
      "0" => %{
        "RECORD0COLUMN0" => "RECORD0VALUE0",
        "RECORD0COLUMN1" => "RECORD0VALUE1"
      },
      "1" => %{
        "RECORD1COLUMN0" => "RECORD1VALUE0",
        "RECORD1COLUMN1" => "RECORD1VALUE1"
      },
      "STATUS" => "DONE"
    }
  defp generate_report_contents(:xml),  do:
  [
    report:
    [
      data:
      [
        record0column0: "record0value0",
        record0column1: "record0value1",
      ],
      data:
      [
        record1column0: "record1value0",
        record1column1: "record1value1",
      ],
    ]
  ]

  defp generate_report_error(:xml), do:
  [
    error:
    [
      errno: "readMore failed",
      description: nil,
      description2: "Results for reportId xyz789 do not exist.",
      correction: nil
    ]
  ]
end
