defmodule Extacct do
  alias Extacct.API
  alias Extacct.RequestWorker

  @all_fields "*"
  @max_list_size "100"

  def get_list(object, max_list_size \\ @max_list_size),   do: elem(API.get_list(object, max_list_size), 1)
  def read(object, keys, fields \\ @all_fields),           do: elem(API.read(object, keys, fields), 1)
  def read_by_name(object, keys, fields \\ @all_fields),   do: elem(API.read_by_name(object, keys, fields), 1)
  def read_by_query(object, query, fields \\ @all_fields), do: elem(API.read_by_query(object, query, fields), 1)
  def read_report(report_name, handler),                   do: RequestWorker.read_report(report_name, handler)
  def read_more(method, identifier),                       do: elem(API.read_more(method, identifier), 1)

end
