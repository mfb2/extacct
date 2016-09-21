defmodule Extacct.MessageBuilderTest do
  use ExUnit.Case

  alias Extacct.API.MessageBuilder
  alias Extacct.API.FunctionBuilder

  @control_id "testFunctionId"
  @dtd_version "3.0"
  @report_name "Report - Important Information Here"
  @return_definitions false

  doctest Extacct.API.MessageBuilder

  test "generates a valid control tuple" do
    assert expected_control == MessageBuilder.control(@control_id)
  end

  test "generates a valid authentication tuple" do
    assert expected_authentication == MessageBuilder.authentication
  end

  test "generates a valid operation tuple" do
    report = generate_report
    assert expected_operation(report) == MessageBuilder.operation(report)
  end

  test "generates a valid request tuple" do
    report = generate_report
    assert expected_request(report) == MessageBuilder.request(report, @control_id)
  end

  defp generate_report, do: FunctionBuilder.read_report(@report_name, @return_definitions, @control_id)

  defp expected_control, do:
    {
      :control, %{},
      [
        {:senderid,          %{}, "test_sender"          },
        {:password,          %{}, "test_sender_password" },
        {:controlid,         %{}, @control_id            },
        {:uniqueid,          %{}, false                  },
        {:dtdversion,        %{}, @dtd_version           },
        {:includewhitespace, %{}, false                  },
      ]
    }

  defp expected_authentication, do:
    {
      :authentication, %{},
      [
        {
          :login, %{},
          [
            {:userid,    %{}, "test_user"          },
            {:companyid, %{}, "test_company"       },
            {:password,  %{}, "test_user_password" },
          ]
        }
      ]
    }

  defp expected_operation(expected_functions) when is_list(expected_functions), do:
    {:operation, %{}, [expected_authentication] ++ [{:content, %{}, expected_functions}]}
  defp expected_operation(expected_function), do:
    expected_operation([expected_function])

  defp expected_request(functions), do:
    {:request, %{}, [expected_control] ++ [expected_operation(functions)]}
end
