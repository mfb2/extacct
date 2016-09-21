defmodule Extacct do
  alias Extacct.API

  def read(object, keys),                   do: API.read(object, keys)
  def read(object, fields, keys),           do: API.read(object, fields, keys)
  def read_by_name(object, keys),           do: API.read_by_name(object, keys)
  def read_by_name(object, fields, keys),   do: API.read_by_name(object, fields, keys)
  def read_by_query(object, query),         do: API.read_by_query(object, query)
  def read_by_query(object, fields, query), do: API.read_by_query(object, fields, query)
  def read_report(report_name),             do: API.read_report(report_name)
  def read_more(method, identifier),        do: API.read_more(method, identifier)

end
