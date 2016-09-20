defmodule Extacct.FunctionBuilder do
  import Extacct.EnvironmentHelper

  @no_value      ""
  @no_params     %{}
  @return_format "json"

  def read(object, fields, keys, control_id),         do: read_spec(:read, object, fields, keys, control_id)
  def read_by_name(object, fields, keys, control_id), do: read_spec(:readByName, object, fields, keys, control_id)

  defp read_spec(read_type, object, fields, [], control_id),   do: read_spec(read_type, object, fields, @no_value, control_id)
  defp read_spec(read_type, object, fields, keys, control_id), do:
  {
    :function, %{controlid: control_id},
    [
      {
        read_type, @no_params,
        [
          {:object,       @no_params, object         },
          {:fields,       @no_params, fields         },
          {:keys,         @no_params, keys           },
          {:returnFormat, @no_params, @return_format },
        ]
      }
    ]
  }

  def read_by_query(object, fields, query, control_id), do:
  {
    :function, %{controlid: control_id},
    [
      {
        :readByQuery, @no_params,
        [
          {:object,       @no_params, object         },
          {:fields,       @no_params, fields         },
          {:query,        @no_params, query          },
          {:returnFormat, @no_params, @return_format },
        ]
      }
    ]
  }

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

    def read_more(method, report_id, control_id) do
      {
        :function, %{controlid: control_id},
        [
          {
            :readMore, @no_params,
            [
              {method, @no_params, report_id}
            ]
          }
        ]
      }
    end
end
