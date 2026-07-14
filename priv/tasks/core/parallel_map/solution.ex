defmodule ParallelMap do
  def map(list, fun, opts) do
    max_concurrency = Keyword.fetch!(opts, :max_concurrency)
    timeout = Keyword.fetch!(opts, :timeout)

    list
    |> Task.async_stream(
      fn element ->
        try do
          {:ok, fun.(element)}
        rescue
          _ -> {:error, :crashed}
        catch
          :exit, _ -> {:error, :crashed}
        end
      end,
      max_concurrency: max_concurrency,
      timeout: timeout,
      on_timeout: :kill_task,
      ordered: true
    )
    |> Enum.map(fn
      {:ok, inner} -> inner
      {:exit, :timeout} -> {:error, :timeout}
      {:exit, _} -> {:error, :crashed}
    end)
  end
end
