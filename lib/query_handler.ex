defmodule Extacct.QueryHandler do

  @callback handle_query_results(list, any) :: {:noreply, any}
  @callback handle_query_error(list, any) :: {:noreply, any}
  @callback handle_query_end(String.t, any) :: {:stop, :normal | list, any}

  defmacro __using__(_env) do
    quote do
      @behaviour Extacct.QueryHandler

      def handle_info({:query_results, data}  = payload, state), do: handle_query_results(payload, state)
      def handle_info({:query_error, message} = payload, state), do: handle_query_error(payload, state)
      def handle_info({:query_end, report_id} = payload, state), do: handle_query_end(payload, report_id)
    end
  end
end
