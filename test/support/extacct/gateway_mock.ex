defmodule Extacct.API.GatewayMock do
  alias Extacct.API.GatewayResponse
  alias Extacct.API.GatewayResponse.Headers

  @control_id          "testFunctionId"
  @results_report_id   "abc123"
  @completed_report_id "xyz789"
  @pending_status      "PENDING"
  @object_start        "glentry"
  @object_end          "glaccount"
  @object_error        "appayment"
  @total 3

  def process(xml, :read_report) do
    cond do
      xml =~ "GenServer Test Report Results" -> %GatewayResponse{headers: generate_headers(:success), content: [report_results: report_status(:results)]}
      xml =~ "GenServer Test Report End"     -> %GatewayResponse{headers: generate_headers(:success), content: [report_results: report_status(:completed)]}
      xml =~ "Rando Report"                  -> %GatewayResponse{headers: generate_headers(:success), content: [report_results: report_status(:results)]}
      xml =~ "Broken Report"                 -> %GatewayResponse{headers: generate_headers(:failure), content: generate_report_error("Broken Report")}
    end
  end
  def process(xml, :read_more) do
    cond do
      xml =~ @results_report_id   -> %GatewayResponse{headers: generate_headers(:success), content: generate_report_contents}
      xml =~ @completed_report_id -> %GatewayResponse{headers: generate_headers(:success), content: generate_report_error(@completed_report_id)}
    end
  end
  def process(_xml, :read_by_name),  do: %GatewayResponse{headers: generate_headers(:success), content: object_list}
  def process(_xml, :read_by_query), do: %GatewayResponse{headers: generate_headers(:success), content: object_list}
  def process(_xml, :read),          do: %GatewayResponse{headers: generate_headers(:success), content: object_list}
  def process(xml, :get_list) do
    cond do
      xml =~ @object_start ->
        %GatewayResponse
        {
          headers: %Headers
          {
            control_id: @control_id,
            status: :success,
            total: @total,
            first_record: 0,
            last_record: 1
          },
          content: object_list(:get_list, :start)
        }
      xml =~ @object_end ->
        %GatewayResponse
        {
          headers: %Headers
          {
            control_id: @control_id,
            status: :success,
            total: @total,
            first_record: 1,
            last_record: 2
          },
          content: object_list(:get_list, :end)
        }
      xml =~ @object_error ->
        %GatewayResponse
        {
          headers: %Headers
          {
            control_id: @control_id,
            status: :failure,
          },
          content: object_list(:get_list, :error)
        }
    end
  end

  defp generate_headers(status), do: %Headers{control_id: @control_id, status: status}

  defp report_status(:results),   do: [reportid: @results_report_id,   status: @pending_status]
  defp report_status(:completed), do: [reportid: @completed_report_id, status: @pending_status]

  defp object_list,                    do: [glentry: [recordno: "1000", entry_date: "09/16/2016"]]
  defp object_list(:get_list, :start), do: [glentry: [key: "1", datecreated: "09/16/2016"],
                                            glentry: [key: "2", datecreated: "09/16/2016"]]
  defp object_list(:get_list, :end),   do: [glentry: [key: "2", datecreated: "09/16/2016"],
                                            glentry: [key: "3", datecreated: "09/16/2016"]]
  defp object_list(:get_list, :error), do: generate_get_list_error
  defp generate_report_contents, do:
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

  defp generate_report_error(report_name), do:
  [
    error:
    [
      errno: "readMore failed",
      description: nil,
      description2: "Results for reportId #{report_name} do not exist.",
      correction: nil
    ]
  ]

  defp generate_get_list_error, do:
  [
    error:
    [
      errno: "get_list failed",
      description: nil,
      description2: "get_list failed",
      correction: nil
    ]
  ]
end
