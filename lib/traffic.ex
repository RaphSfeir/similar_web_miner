defmodule SimilarWebMiner.Traffic do
  alias SimilarWebMiner.Traffic

  @moduledoc """
  Handle traffic info extraction
  """

  @doc """
  Process similar web records of geography repartition
  """
  def process_result_list(records) when is_list(records) do
    records
    |> Enum.map(&Traffic.extract_visit/1)
  end

  def extract_visit(
        _visit = %{
          "visits" => visits,
          "date" => date
        }
      ) do
    %{
      visits: visits,
      date: Date.from_iso8601!(date)
    }
  end

  def process_result_visitors(records) when is_list(records) do
    records
    |> Enum.map(&Traffic.extract_visitors/1)
  end

  def extract_visitors(
        _visit = %{
          "unique_visitors" => unique_visitors,
          "date" => date
        }
      ) do
    %{
      unique_visitors: unique_visitors,
      date: Date.from_iso8601!(date)
    }
  end
end
