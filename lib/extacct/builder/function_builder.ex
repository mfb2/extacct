defmodule Extacct.FunctionBuilder do
  import Extacct.EnvironmentHelper

  @no_value      ""
  @no_params     %{}
  @return_format "json"

  def read_report(report_name, return_definitions, control_id), do:
    {
      :function, %{controlid: control_id},
      [
        {
          :readReport, %{returnDef: return_definitions},
          [
            {:report,        @no_params, report_name         },
            {:pagesize,      @no_params, env_var(:page_size) },
            {:waitTime,      @no_params, env_var(:wait_time) },
            {:returnFormat,  @no_params, @return_format      },
            {:listSeparator, @no_params, @no_value           },
          ]
        }
      ]
    }

    def read_more(report_id, control_id) do
      {
        :function, %{controlid: control_id},
        [
          {
            :readMore, @no_params,
            [
              {:reportId, @no_params, report_id}
            ]
          }
        ]
      }
    end
end
