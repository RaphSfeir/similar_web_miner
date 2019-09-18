defmodule SimilarWebMiner.Geography do
  alias SimilarWebMiner.Geography

  @moduledoc """
  Handle geographic info extraction
  """

  def extract_info(
        _geographic_info = %{
          "country" => country_code,
          "share" => share,
          "visits" => visits,
          "pages_per_visit" => pages_per_visit,
          "average_time" => average_time,
          "bounce_rate" => bounce_rate,
          "rank" => rank
        }
      ) do
    %{
      country: get_country_by_code(country_code),
      country_code: country_code,
      share: share,
      visits: visits,
      pages_per_visit: pages_per_visit,
      average_time: average_time,
      bounce_rate: bounce_rate,
      rank: rank
    }
  end

  @doc """
  Make sure a country code is three digits

  ## Examples
  iex> SimilarWebMiner.Geography.convert_code_to_three_digits("5") 
  "005"

  iex> SimilarWebMiner.Geography.convert_code_to_three_digits("250") 
  "250"
  """
  def convert_code_to_three_digits(code) when is_binary(code) do
    code
    |> String.pad_leading(3, "0")
  end

  def convert_code_to_three_digits(code) when is_number(code) do
    code
    |> Integer.to_string()
    |> convert_code_to_three_digits
  end

  @doc """
  Get country name by country code
  #
  ## Examples
  iex> SimilarWebMiner.Geography.get_country_by_code("250") 
  "France"

  iex> SimilarWebMiner.Geography.get_country_by_code(250) 
  "France"

  iex> SimilarWebMiner.Geography.get_country_by_code("51") 
  "Armenia"
  """
  def get_country_by_code(country_code) do
    three_digits_code =
      country_code
      |> convert_code_to_three_digits

    case filter_countries_by(three_digits_code) do
      {:ok, country_name} ->
        country_name

      false ->
        {code_int, ""} = Integer.parse(three_digits_code)

        case filter_countries_by(code_int) do
          {:ok, country_name} ->
            country_name

          false ->
            false
        end
    end
  end

  def filter_countries_by(three_digits_code) do
    case Countries.filter_by(:number, three_digits_code) do
      [
        %{
          name: country_name
        }
      ] ->
        {:ok, country_name}

      [] ->
        false
    end
  end

  @doc """
  Process similar web records of geography repartition
  """
  def process_result_list(records) when is_list(records) do
    records
    |> Enum.map(&Geography.extract_info/1)
  end
end
