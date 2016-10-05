defmodule Extacct.ReportHandler do

  @callback handle_report_results(list, any) :: {:noreply, any}
  @callback handle_report_error(list, any) :: {:noreply, any}
  @callback handle_report_end(String.t, any) :: {:stop, :normal | list, any}

  defmacro __using__(_env) do
    quote do
      @behaviour Extacct.ReportHandler

      def handle_info({:report_results, data} = payload, state),  do: handle_report_results(payload, state)
      def handle_info({:report_error, message} = payload, state), do: handle_report_error(payload, state)
      def handle_info({:report_end, report_id} = payload, state), do: handle_report_end(payload, report_id)
    end
  end
end
