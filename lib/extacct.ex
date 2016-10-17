defmodule Extacct do
  alias Extacct.API
  alias Extacct.RequestWorker

  @all_fields "*"
  @max_list_size "100"

  @moduledoc """
  This module provides client-facing functions for interacting with the 
  Intacct API.
  """

  @doc """
  Read an object from the Intacct API.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `object` - The name of the object to be read from Intacct.

    Examples: `"GLENTRY"`, `"GLACCOUNT"`, etc.

    * `keys` - A list of unique identifiers for the requested object records.

    Example: `[100, 101, 102]`

    * `fields` - (Optional): A list of fields requested back from the Intacct for that object.

    Example: `["ENTRY_DATE", "RECORDNO"]`

  ## Examples

      iex> Extacct.read "GLENTRY", []
      [glentry: [recordno: "1000", entry_date: "09/16/2016"]]

  """
  @spec read(String.t, list, list) :: [key: list | String.t]
  def read(object, keys, fields \\ @all_fields), do:
    elem(API.read(object, keys, fields), 3)

  @doc """
  Read an object by name from the Intacct API.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `object` - The name of the object to be read from Intacct.

    Examples: `"GLENTRY"`, `"GLACCOUNT"`, etc.

    * `keys` - A list of unique identifiers for the requested object records.

    Example: `[100, 101, 102]`

    * `fields` (Optional) - A list of fields requested back from the Intacct for that object.

    Example: `["ENTRY_DATE", "RECORDNO"]`

  ## Examples

      iex> Extacct.read_by_name "GLENTRY", "Ledger Entry"
      [glentry: [recordno: "1000", entry_date: "09/16/2016"]]

  """
  @spec read_by_name(String.t, list, list) :: [key: list | String.t]
  def read_by_name(object, keys, fields \\ @all_fields), do:
    elem(API.read_by_name(object, keys, fields), 3)

  @doc """
  Read an object by query from the Intacct API.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `object` - The name of the object to be read from Intacct.

    Examples: `"GLENTRY"`, `"GLACCOUNT"`, etc.

    * `query` - A query that conforms to the specifications provided by Intacct.
    See the [developer documentation for `ReadByQuery()`](https://developer.intacct.com/wiki/readbyquery).

    Example: `[100, 101, 102]`

    * `handler` - A handler for processing records returned by the Intacct API.
    Must conform to the behaviour specified in the `QueryHandler` module.

  """
  @spec read_by_query(String.t, String.t, pid) :: [key: list | String.t]
  def read_by_query(object, query, handler), do:
    read_by_query(object, query, @all_fields, handler)

  @doc """
  Read an object by query from the Intacct API.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `object` - The name of the object to be read from Intacct.

    Examples: `"GLENTRY"`, `"GLACCOUNT"`, etc.

    * `query` - A query that conforms to the specifications provided by Intacct.
    See the [developer documentation for `ReadByQuery()`](https://developer.intacct.com/wiki/readbyquery).

    Example: `[100, 101, 102]`

    * `fields` (Optional) - A list of fields requested back from the Intacct for that object. 

    Example: `["ENTRY_DATE", "RECORDNO"]`

    * `handler` - A handler for processing records returned by the Intacct API.
    Must conform to the behaviour specified in the `QueryHandler` module.

  """
  @spec read_by_query(String.t, String.t, list, pid) :: [key: list | String.t]
  def read_by_query(object, query, fields, handler), do:
    RequestWorker.read_by_query(object, query, fields, handler)

  @doc """
  Read additional data from the Intacct API.

  Returns additional data in accordance with the rules specified by the Intacct API.
  See the [developer documentation for `ReadMore()`](https://developer.intacct.com/wiki/readmore) for more information.

  ## Arguments

    * `method` - The type of `read_more` operation to invoke.

    * `identifier` - The unique identifier to be used in conjunction with the
    method for reading additional data from Intacct.

  ## Examples

      iex> Extacct.read_more :reportId, "abc123"
      [report: [data: [record0column0: "record0value0", record0column1: "record0value1"], data: [record1column0: "record1value0", record1column1: "record1value1"]]]

  """
  @spec read_more(:object | :view | :reportId, String.t) :: [key: list | String.t]
  def read_more(method, identifier), do:
    elem(API.read_more(method, identifier), 3)

  @doc """
  Read a custom report from the Intacct API.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `report_name` - The name of the custom report in Intacct.

    * `handler` - A handler for processing records returned by the Intacct API.
    Must conform to the behaviour specified in the `ReportHandler` module.

  """
  @spec read_report(String.t, pid) :: [key: list | String.t]
  def read_report(report_name, handler), do:
    RequestWorker.read_report(report_name, handler)

  @doc """
  Read a list of entries from the Intacct API for supported object types.

  Returns a list of entries corresponding to the object.

  ## Arguments

    * `object` - The name of the object to be read from Intacct.

    Examples: `"GLENTRY"`, `"GLACCOUNT"`, etc.

    * `handler` - A handler for processing records returned by the Intacct API.
    Must conform to the behaviour specified in the `GetListHandler` module.

  """
  @spec get_list(String.t, pid) :: [key: list | String.t]
  def get_list(object, handler), do:
    RequestWorker.get_list(object, handler)

end
