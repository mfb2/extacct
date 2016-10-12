defmodule Extacct.APITest do
  use ExUnit.Case
  alias Extacct.API

  @control_id "testFunctionId"
  @report_name "Rando Report"
  @bad_report_name "Broken Report"
  @report_id_key "REPORTID"
  @report_id_value "abc123"
  @report_record_zero "0"
  @report_record_one "1"
  @report_status_key "STATUS"
  @report_status_value "DONE"
  @object "GLENTRY"
  @object_name "Ledger Entry"
  @object_query "ENTRY_DATE > '09/01/2016'"
  @total 3
  @last_record 1
  @first_record 0

  test "can readReport from Extacct API" do
    {:read_report, @control_id, metadata, content} = API.read_report(@report_name)
    verify_metadata(metadata, :success)
    verify_report_response(content)
  end

  def verify_report_response(content) do
    assert content == [report_results: [reportid: "abc123", status: "PENDING"]]
  end

  test "can readMore from Extacct API" do
    {:read_more, @control_id, metadata, response} = API.read_more(:reportId, @report_id_value)
    verify_metadata(metadata, :success)
    verify_report_values(response)
  end

  defp verify_report_values([report: report]), do: Enum.each(report, &verify_report_entry(&1))
  defp verify_report_entry(entry) do
    entry
    |> elem(1)
    |> Enum.map(fn
        {:record0column0, "record0value0"} -> true
        {:record0column1, "record0value1"} -> true
        {:record1column0, "record1value0"} -> true
        {:record1column1, "record1value1"} -> true
        unrecognized_entry                 -> flunk "Unrecognized report entry: #{unrecognized_entry}"
    end)
  end

  test "can read from Extacct API" do
    {:read, @control_id, metadata, object_data} = API.read(@object, [])
    verify_metadata(metadata, :success)
    verify_object_data(object_data)
  end

  test "can read by name from Extacct API" do
    {:read_by_name, @control_id, metadata, object_data} = API.read_by_name(@object, @object_name)
    verify_metadata(metadata, :success)
    verify_object_data(object_data)
  end

  test "can read by query from Extacct API" do
    {:read_by_query, @control_id, metadata, object_data} = API.read_by_query(@object, @object_query)
    verify_metadata(metadata, :success)
    verify_object_data(object_data)
  end

  defp verify_object_data(object_data), do:
    assert object_data == [glentry: [recordno: "1000", entry_date: "09/16/2016"]]

  test "bad requests return an error" do
    {:read_report, @control_id, metadata, bad_report_response} = API.read_report(@bad_report_name)
    verify_metadata(metadata, :failure)
    verify_bad_report_content(bad_report_response)
  end

  defp verify_bad_report_content(content) do
    assert content == expected_bad_report_response
  end

  defp expected_bad_report_response, do:
    [
      error:
      [
        errno: "readMore failed",
        description: nil,
        description2: "Results for reportId #{@bad_report_name} do not exist.",
        correction: nil
      ]
    ]

  test "can get a list of entries from the Extacct API" do
    {:get_list, @control_id, metadata, get_list_response} = API.get_list(@object)
    verify_metadata(metadata, :success, :get_list)
    verify_get_list_content(get_list_response)
  end

  defp verify_get_list_content(content) do
    assert expected_get_list_results == content
  end

  defp expected_get_list_results, do:
    [
      glentry: [key: "1", datecreated: "09/16/2016"],
      glentry: [key: "2", datecreated: "09/16/2016"],
    ]

  defp verify_metadata(metadata, status, function \\ nil)
  defp verify_metadata(metadata, status, _function) when is_map(metadata) do
    assert metadata.status     == status
  end
  defp verify_metadata(metadata, status, :get_list) when is_map(metadata) do
    assert metadata.status       == status
    assert metadata.total        == @total
    assert metadata.first_record == @first_record
    assert metadata.last_record  == @last_record
  end
  defp verify_metadata(metadata, _status, _function) do
    flunk "Expected map of headers, got #{metadata}"
  end
end
