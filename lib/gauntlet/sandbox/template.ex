defmodule Gauntlet.Sandbox.Template do
  @moduledoc """
  Prepares the warmed sandbox template a run copies per attempt.

  The template is a dependency-free mix project (`priv/sandbox_template/`).
  `prepare/1` copies it into the run's work dir, pins the toolchain by
  copying the harness repo's `.tool-versions`, and compiles once so every
  attempt starts from a warm `_build`.
  """

  @doc """
  Materialize and warm the template under `work_dir/template`.
  Returns the template path.
  """
  @spec prepare(String.t()) :: {:ok, String.t()} | {:error, term()}
  def prepare(work_dir) do
    template_dir = Path.join(work_dir, "template")
    File.mkdir_p!(template_dir)
    File.cp_r!(source_dir(), template_dir)
    copy_tool_versions(template_dir)

    case warm(template_dir) do
      :ok -> {:ok, template_dir}
      error -> error
    end
  end

  @doc "The pristine template source inside the gauntlet repo."
  @spec source_dir() :: String.t()
  def source_dir do
    Path.join(:code.priv_dir(:gauntlet), "sandbox_template")
  end

  defp copy_tool_versions(template_dir) do
    candidates = [
      Path.join(File.cwd!(), ".tool-versions"),
      Path.expand("../../../.tool-versions", :code.priv_dir(:gauntlet))
    ]

    case Enum.find(candidates, &File.regular?/1) do
      nil -> :ok
      path -> File.cp!(path, Path.join(template_dir, ".tool-versions"))
    end
  end

  defp warm(template_dir) do
    {output, status} =
      System.cmd("mix", ["compile"],
        cd: template_dir,
        env: [{"MIX_ENV", "test"}],
        stderr_to_stdout: true
      )

    if status == 0 do
      :ok
    else
      {:error, {:template_compile_failed, output}}
    end
  end
end
