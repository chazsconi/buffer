defmodule Buffer.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_buffer,
      version: "0.2.0",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      deps: deps(),
      name: "Buffer",
      source_url: "https://github.com/chazsconi/buffer",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    FIFO buffers for queueing
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :simple_buffer,
      maintainers: ["Charles Bernasconi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/chazsconi/buffer"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme"
    ]
  end
end
