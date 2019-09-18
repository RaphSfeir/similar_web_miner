defmodule SimilarWebMiner do
  alias SimilarWebMiner.Geography

  @moduledoc """
  Client for calls to the Similar Web API, regarding geography repartition (for now).
  """

  @doc """
  Similar Web Data Collector 

  """

  @api_uri "https://api.similarweb.com/v1/website"

  def geography_repartition(domain, start_date \\ "2019-07", end_date \\ "2019-08") do
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{domain}/Geo/traffic-by-country?api_key=#{api_key}&start_date=#{start_date}&end_date=#{
        end_date
      }&main_domain_only=false"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body),
         {:ok, records} <- extract_records(body),
         countries_with_shares <- Geography.process_result_list(records) do
      countries_with_shares
    else
      err -> {:error, err}
    end
  end

  defp extract_records(%{"records" => records}) when is_list(records) do
    {:ok, records}
  end

  defp post_process_call(%HTTPoison.Response{body: body, status_code: 200}) do
    {:ok, body}
  end

  defp post_process_json_body(json_body) when is_binary(json_body) do
    Jason.decode(json_body)
  end

  defp get_api_key do
    System.get_env("SIMILAR_WEB_API_TOKEN")
  end
end
