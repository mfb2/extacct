defmodule Extacct.APITest do
  use ExUnit.Case
  alias Extacct.API

  @report_name "Rando Report"
  @bad_report_name "Broken Report"
  @report_id_key "REPORTID"
  @report_id_value "123"
  @report_record_zero "0"
  @report_record_one "1"
  @report_status_key "STATUS"
  @report_status_value "DONE"
  @object "GLENTRY"
  @object_name "Ledger Entry"
  @object_query "ENTRY_DATE > '09/01/2016'"

  test "can readReport from Extacct API" do
    {:read_report, response_content} = API.read_report(@report_name)
    assert response_content == [report_results: [reportid: "abc123", status: "PENDING"]]
  end

  test "can readMore from Extacct API" do
    {:read_more, report} = API.read_more(:reportId, @report_id_value)

    verify_report_keys(report)
    verify_report_values(report)
  end

  defp verify_report_keys(report) do
    keys = Map.keys(report)
    assert Enum.count(keys) == 3
    assert Enum.member?(keys, @report_record_zero)
    assert Enum.member?(keys, @report_record_one)
    assert Enum.member?(keys, @report_status_key)
  end

  defp verify_report_values(report), do: Enum.each(report, &verify_report_entry(&1))
  defp verify_report_entry({@report_status_key, @report_status_value}), do: true
  defp verify_report_entry({@report_record_zero, report_record_value}), do: verify_report_entry_values(@report_record_zero, report_record_value)
  defp verify_report_entry({@report_record_one,  report_record_value}), do: verify_report_entry_values(@report_record_one,  report_record_value)

  defp verify_report_entry_values(report_record_key, report_record_value) do
    verify_report_entry_value(report_record_key, report_record_value, 0)
    verify_report_entry_value(report_record_key, report_record_value, 1)
  end

  defp verify_report_entry_value(report_record_key, report_record_value, entry_value_index) do
    entry_value = get_report_entry_value(report_record_key, report_record_value, entry_value_index)
    refute is_nil(entry_value)
    assert entry_value == "RECORD#{report_record_key}VALUE#{entry_value_index}"
  end

  defp get_report_entry_value(report_record_key, report_record_value, entry_value_index) do
    Map.get(report_record_value, "RECORD#{report_record_key}COLUMN#{entry_value_index}")
  end

  test "can read from Extacct API" do
    {:read, object_data} = API.read(@object, [])
    verify_object_data(object_data)
  end

  test "can read by name from Extacct API" do
    {:read_by_name, object_data} = API.read_by_name(@object, @object_name)
    verify_object_data(object_data)
  end

  test "can read by query from Extacct API" do
    {:read_by_query, object_data} = API.read_by_query(@object, @object_query)
    verify_object_data(object_data)
  end

  defp verify_object_data(object_data), do:
    assert object_data == [glentry: [recordno: "1000", entry_date: "09/16/2016"]]

  test "bad requests return an error" do
    assert expected_bad_report_response == API.read_report(@bad_report_name)
  end

  defp expected_bad_report_response, do:
    {
      :read_report,
      [
        error:
        [
          errno: "readMore failed",
          description: nil,
          description2: "Results for reportId #{@bad_report_name} do not exist.",
          correction: nil
        ]
      ]
    }

  test "can get a list of entries from the Extacct API" do
    assert expected_get_list_results == API.get_list(@object)
  end

  defp expected_get_list_results, do:
    {:get_list,
      [
        glentry: [key: "1", datecreated: "09/16/2016"],
        glentry: [key: "2", datecreated: "09/16/2016"],
      ]
    }
end
