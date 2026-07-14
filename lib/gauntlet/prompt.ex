defmodule Gauntlet.Prompt do
  @moduledoc """
  Versioned prompt templates (EEx, under `priv/prompts/`).

  `build/3` returns the message list for a task plus the template versions
  used, which are recorded in run metadata for reproducibility.
  """

  alias Gauntlet.Task

  @versions %{system: "v1", gen: "v1", fix: "v1", predict: "v1", mcq: "v1", repair: "v1"}

  @type built :: %{messages: [Gauntlet.Model.Adapter.message()], versions: map()}

  @doc """
  Build the initial message list for a task.

  Options:
    * `:context_injection` - include the task's context.md if present (default false)
  """
  @spec build(Task.t(), keyword()) :: built()
  def build(%Task{} = task, opts \\ []) do
    context = if Keyword.get(opts, :context_injection, false), do: task.context

    user =
      case task.type do
        :write_code ->
          render(:gen,
            prompt: task.prompt,
            module_name: task.module_name,
            stub: task.stub,
            context: context
          )

        :fix_code ->
          render(:fix,
            prompt: task.prompt,
            module_name: task.module_name,
            buggy: task.buggy,
            failure_output: task.failure_output,
            context: context
          )

        :predict_output ->
          render(:predict, prompt: task.prompt, stub: task.stub)

        :mcq ->
          render(:mcq, prompt: task.prompt, stub: task.stub)
      end

    %{
      messages: [
        %{role: :system, content: system_prompt()},
        %{role: :user, content: user}
      ],
      versions: @versions
    }
  end

  @doc """
  Build the repair follow-up message (round 2) from the failure output.
  Appended to the original conversation together with the assistant's reply.
  """
  @spec repair_message(Task.t(), String.t()) :: Gauntlet.Model.Adapter.message()
  def repair_message(%Task{} = task, failure_output) do
    %{
      role: :user,
      content: render(:repair, module_name: task.module_name, failure_output: failure_output)
    }
  end

  @doc "The template versions map recorded in run metadata."
  @spec versions() :: map()
  def versions, do: @versions

  defp system_prompt do
    render(:system,
      elixir_version: System.version(),
      otp_release: System.otp_release()
    )
  end

  defp render(template, assigns) do
    path =
      Path.join(
        :code.priv_dir(:gauntlet),
        "prompts/#{template}_#{@versions[template]}.md.eex"
      )

    path
    |> EEx.eval_file(assigns: Map.new(assigns))
    |> String.trim()
  end
end
