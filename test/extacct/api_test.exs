defmodule Extacct.APITest do
  use ExUnit.Case
  alias Extacct.API
  doctest Extacct.API

  @report_name "Rando Report"
  @report_id_key "REPORTID"
  @report_id_value "random_string"
  @report_record_zero "0"
  @report_record_one "1"
  @report_status_key "STATUS"
  @report_status_value "DONE"
  @object_name "GLENTRY"
  @object_query "ENTRY_DATE > '09/01/2016'"

  test "can readReport from Extacct API" do
    entry = API.read_report(@report_name)
    |> Map.get(@report_id_key)

    if is_nil(entry) do
      flunk "REPORTID missing from report"
    end

    assert entry == @report_id_value
  end

  test "can readMore from Extacct API" do
    report = API.read_more(:reportId, @report_id_value)

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
  defp verify_report_entry({@report_status_key, @report_status_value}), do: assert true
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
    object_data = API.read(@object_name, [])
    verify_object_data(object_data)
  end

  test "can read by name from Extacct API" do
    object_data = API.read_by_name(@object_name, "Ledger Entry")
    verify_object_data(object_data)
  end

  test "can read by query from Extacct API" do
    object_data = API.read_by_query(@object_name, @object_query)
    verify_object_data(object_data)
  end

  defp verify_object_data(object_data), do:
    assert object_data == %{"ENTRY_DATE" => "09/16/2016", "RECORDNO" => "1000"}
end
