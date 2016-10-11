defmodule Extacct.RequestWorkerTest do
  use ExUnit.Case
  alias Extacct.RequestWorker
  doctest Extacct.RequestWorker

  @results_report_name   "GenServer Test Report Results"
  @completed_report_name "GenServer Test Report End"
  @report_id_key         "REPORTID"
  @report_id_value_1     "first_result"
  @report_id_value_2     "last_result"
  @report_record_zero    "0"
  @report_record_one     "1"
  @report_status_key     "STATUS"
  @report_status_value   "DONE"
  @all_keys              []
  @all_fields            "*"
  @object_start          "GLENTRY"
  @object_end            "GLACCOUNT"
  @object_name           "Ledger Entry"
  @object_query          "ENTRY_DATE > '09/01/2016'"

  test "can issue readReport command to API request worker and receive results" do
    RequestWorker.read_report(@results_report_name, self)
    assert_receive {:report_results, _results}
  end

  test "can issue readReport command to API request worker and reach end of the report" do
    RequestWorker.read_report(@completed_report_name, self)
    assert_receive {:report_end, _report_id}
  end

  test "can issue get_list command to API request worker and receive results" do
    RequestWorker.get_list(@object_start, self)
    assert_receive {:get_list_results, _record_metadata}
  end

  test "can issue get_list command to API request worker and reach end of results" do
    RequestWorker.get_list(@object_end, self)
    assert_receive {:get_list_end, _record_metadata}
  end

end
