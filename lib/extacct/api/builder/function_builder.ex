defmodule Extacct.API.FunctionBuilder do
  import Extacct.EnvironmentHelper

  @no_value      ""
  @no_params     %{}


  def read(object, fields, keys, control_id) do
    read_spec(:read, object, fields, keys)
    |> function_spec(control_id)
  end
  def read_by_name(object, fields, keys, control_id) do
    read_spec(:readByName, object, fields, keys)
    |> function_spec(control_id)
  end

  def read_report(report_name, return_definitions, control_id) do
    read_report_spec(report_name, return_definitions)
    |> function_spec(control_id)
  end

  def read_more(method, item_id, control_id) do
    read_more_spec(method, item_id)
    |> function_spec(control_id)
  end

  def read_by_query(object, fields, query, control_id) do
    read_by_query_spec(object, fields, query)
    |> function_spec(control_id)
  end

  defp read_spec(read_type, object, fields, []),   do: read_spec(read_type, object, fields, @no_value)
  defp read_spec(read_type, object, fields, keys), do:
  {
    read_type, @no_params,
    [
      {:object,       @no_params, object        },
      {:fields,       @no_params, fields        },
      {:keys,         @no_params, keys          },
      {:returnFormat, @no_params, return_format },
    ]
  }

  def read_by_query_spec(object, fields, query), do:
  {
    :readByQuery, @no_params,
    [
      {:object,       @no_params, object        },
      {:fields,       @no_params, fields        },
      {:query,        @no_params, query         },
      {:returnFormat, @no_params, return_format },
    ]
  }

  def read_report_spec(report_name, return_definitions), do:
  {
    :readReport, %{returnDef: return_definitions},
    [
      {:report,        @no_params, report_name         },
      {:pagesize,      @no_params, env_var(:page_size) },
      {:waitTime,      @no_params, env_var(:wait_time) },
      {:returnFormat,  @no_params, return_format       },
      {:listSeparator, @no_params, @no_value           },
    ]
  }

  def read_more_spec(method, item_id), do:
  {
    :readMore, @no_params,
    [
      {method, @no_params, item_id}
    ]
  }

  defp function_spec(inner_request, control_id), do: {:function, %{controlid: control_id}, [inner_request]}

  defp return_format, do: env_var(:return_format)
end
