defmodule SimilarWebMiner.MixProject do
  use Mix.Project

  def project do
    [
      app: :similar_web_miner,
      version: "0.1.9",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      name: "Similar Web Miner",
      source_url: "https://github.com/RaphSfeir/similar_web_miner",
      homepage_url: "https://github.com/RaphSfeir/similar_web_miner",
      docs: [
        main: "SimilarWebMiner",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Small library to call the Similar Web Geography API endpoint."
  end

  defp deps do
    [
      {:countries, "~> 1.5"},
      {:httpoison, "~> 1.8"},
      {:timex, "~> 3.7"},
      {:csv, "~> 2.4"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:jason, "~> 1.2"}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "Similar Web API" => "https://www.similarweb.com/corp/developer/estimated_visits_api",
        "Github repo" => "https://github.com/RaphSfeir/similar_web_miner"
      }
    ]
  end
end
