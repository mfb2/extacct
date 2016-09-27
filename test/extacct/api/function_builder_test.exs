defmodule Extacct.FunctionBuilderTest do
  use ExUnit.Case
  import Extacct.EnvironmentHelper
  alias Extacct.API.FunctionBuilder

  @control_id         "testFunctionId"
  @report_name        "Report - Very Important Report"
  @return_definitions false
  @no_value           ""
  @no_params          %{}
  @return_format      "xml"
  @object_name        "GLENTRY"
  @all_fields         "*"
  @object_entry_date  "09/16/2016"
  @object_record_id   "1000"
  @object_name        "Ledger Entry"
  @object_query       "ENTRY_DATE > '09/01/2016'"

  doctest Extacct.API.FunctionBuilder

  test "generates a valid readReport tuple" do
    assert expected_read_report == generate_report
  end

  test "generates a valid read tuple" do
    assert expected_read_object == read_object
  end

  test "generates a valid read by name tuple" do
    assert expected_read_by_name == read_by_name
  end

  test "generates a valid read by query tuple" do
    assert expected_read_by_query == read_by_query
  end

  def generate_report, do: FunctionBuilder.read_report(@report_name, @return_definitions, @control_id)
  def read_object,     do: FunctionBuilder.read(@object_name, @all_fields, [], @control_id)
  def read_by_name,    do: FunctionBuilder.read_by_name(@object_name, @all_fields, @object_name, @control_id)
  def read_by_query,   do: FunctionBuilder.read_by_query(@object_name, @all_fields, @object_query, @control_id)

  defp expected_read_report, do:
    {
      :function, %{controlid: @control_id},
      [
        {
          :readReport, %{returnDef: @return_definitions},
          [
            {:report,        @no_params, @report_name        },
            {:pagesize,      @no_params, env_var(:page_size) },
            {:waitTime,      @no_params, env_var(:wait_time) },
            {:returnFormat,  @no_params, @return_format      },
            {:listSeparator, @no_params, @no_value           },
          ]
        }
      ]
    }

  defp expected_read_object, do:
    {
      :function, %{controlid: @control_id},
      [
        {
          :read, @no_params,
          [
            {:object,       @no_params, @object_name   },
            {:fields,       @no_params, @all_fields    },
            {:keys,         @no_params, @no_value      },
            {:returnFormat, @no_params, @return_format },
          ]
        }
      ]
    }

  defp expected_read_by_name, do:
    {
      :function, %{controlid: @control_id},
      [
        {
          :readByName, @no_params,
          [
            {:object,       @no_params, @object_name   },
            {:fields,       @no_params, @all_fields    },
            {:keys,         @no_params, @object_name   },
            {:returnFormat, @no_params, @return_format },
          ]
        }
      ]
    }

  defp expected_read_by_query, do:
    {
        :function, %{controlid: @control_id},
      [
        {
          :readByQuery, @no_params,
          [
            {:object,       @no_params, @object_name   },
            {:fields,       @no_params, @all_fields    },
            {:query,        @no_params, @object_query  },
            {:returnFormat, @no_params, @return_format },
          ]
        }
      ]
    }
end
