defmodule Extacct.API.FunctionBuilder do
  import Extacct.EnvironmentHelper

  @no_value      ""
  @no_params     %{}

  def get_list(object, max_list_size, control_id) do
    get_list_spec(object, max_list_size)
    |> function_spec(control_id)
  end

  def get_list(object, start, max_list_size, control_id) do
    get_list_spec(object, start, max_list_size)
    |> function_spec(control_id)
  end

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

  def inspect_detail(object, control_id) do
    inspect_detail_spec(object)
    |> function_spec(control_id)
  end

  defp get_list_spec(object, max_list_size), do:
  {
    :get_list, %{"object" => object, "maxitems" => max_list_size}, []
  }

  defp get_list_spec(object, start, max_list_size), do:
  {
    :get_list, %{"object" => object, "start" => start, "maxitems" => max_list_size}, []
  }

  defp read_spec(read_type, object, fields, []),   do: read_spec(read_type, object, fields, @no_value)
  defp read_spec(read_type, object, fields, keys), do:
  {
    read_type, @no_params,
    [
      {:object,       @no_params, object                },
      {:fields,       @no_params, format_values(fields) },
      {:keys,         @no_params, format_values(keys)   },
      {:returnFormat, @no_params, return_format         },
    ]
  }

  def read_by_query_spec(object, fields, query), do:
  {
    :readByQuery, @no_params,
    [
      {:object,       @no_params, object                },
      {:fields,       @no_params, format_values(fields) },
      {:query,        @no_params, query                 },
      {:pagesize,     @no_params, query_page_size       },
      {:returnFormat, @no_params, return_format         },
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

  def inspect_detail_spec(object), do:
  {
    :inspect, %{detail: "1"},
    [
      {:object, @no_params, object}
    ]
  }

  defp function_spec(inner_request, control_id), do: {:function, %{controlid: control_id}, [inner_request]}

  defp format_values(values) when is_list(values), do: Enum.join(values, ", ")
  defp format_values(values),                      do: values

  defp query_page_size, do: env_var(:query_page_size)
  defp return_format,   do: env_var(:return_format)
end
