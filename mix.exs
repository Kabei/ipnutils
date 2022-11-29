defmodule Ipnutils.MixProject do
  use Mix.Project

  def project do
    [
      app: :ipnutils,
      version: "0.0.1",
      config_path: "config.exs",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :inets, :ecto_sql, :syntax_tools, :logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:jason, "~> 1.3"},
      {:ecto_sql, "~> 3.7"},
      {:cubdb, "~> 2.0.1"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  def package do
    [
      name: :ipnutils,
      description: "IPPAN Utils",
      maintainers: ["Kambei Sapote"],
      licenses: ["MIT"],
      files: ["lib/*", "mix.exs", "README*", "LICENSE*"]
    ]
  end
end
