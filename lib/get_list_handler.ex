defmodule Extacct.GetListHandler do

  @callback handle_get_list_results(list, any) :: {:noreply, any}
  @callback handle_get_list_error(list, any) :: {:noreply, any}
  @callback handle_get_list_end(String.t, any) :: {:stop, :normal | list, any}

  defmacro __using__(_env) do
    quote do
      @behaviour Extacct.GetListHandler

      def handle_info({:get_list_results, data} = payload, state),  do: handle_get_list_results(payload, state)
      def handle_info({:get_list_error, message} = payload, state), do: handle_get_list_error(payload, state)
      def handle_info({:get_list_end, report_id} = payload, state), do: handle_get_list_end(payload, state)
    end
  end
end
