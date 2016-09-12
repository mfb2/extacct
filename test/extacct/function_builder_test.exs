defmodule Extacct.FunctionBuilderTest do
  use ExUnit.Case
  import Extacct.EnvironmentHelper
  alias Extacct.FunctionBuilder

  @control_id "testFunctionId"
  @report_name "Report - Anaplan Exp PLC BS"
  @return_definitions false
  @no_value      ""
  @no_params     %{}
  @return_format "json"

  doctest Extacct.FunctionBuilder

  test "generates a valid readReport tuple" do
    assert expected_read_report == generate_report
  end

  def generate_report, do: FunctionBuilder.read_report(@report_name, @return_definitions, @control_id)

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
end
