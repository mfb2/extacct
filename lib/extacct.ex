defmodule Extacct do
  alias Extacct.API

  @all_fields "*"
  @max_list_size "100"

  def read(object, keys, fields \\ @all_fields),           do: elem(API.read(object, keys, fields), 1)
  def read_by_name(object, keys, fields \\ @all_fields),   do: elem(API.read_by_name(object, keys, fields), 1)
  def read_by_query(object, query, fields \\ @all_fields), do: elem(API.read_by_query(object, query, fields), 1)
  def read_report(report_name),                            do: elem(API.read_report(report_name), 1)
  def read_more(method, identifier),                       do: elem(API.read_more(method, identifier), 1)

end
