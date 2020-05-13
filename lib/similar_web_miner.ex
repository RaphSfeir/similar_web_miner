defmodule SimilarWebMiner do
  alias SimilarWebMiner.Geography
  alias SimilarWebMiner.Traffic

  @moduledoc """
  Client for calls to the Similar Web API, regarding geography repartition (for now).
  """
  @api_uri "https://api.similarweb.com/v1/website"

  @doc """
  get the last 6 months with monthly granularity
  """
  def total_visits_last_months(domain) do
    today = Date.utc_today()
    end_date = get_first_of_month(today)
    start_date = get_first_of_month(Date.add(today, -6 * 30))
    total_visits(domain, start_date, end_date, "monthly")
  end

  def total_visits(
        domain,
        start_date \\ "2020-01",
        end_date \\ "2020-03",
        granularity \\ "monthly"
      ) do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/total-traffic-and-engagement/visits?api_key=#{api_key}&start_date=#{
        start_date
      }&end_date=#{end_date}&country=world&granularity=#{granularity}&main_domain_only=false&format=json"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body),
         {:ok, records} <- extract_visits(body),
         monthly_visits <- Traffic.process_result_list(records) do
      monthly_visits
    else
      err -> {:error, err}
    end
  end

  def geography_repartition(domain, start_date \\ "2019-07", end_date \\ "2019-08") do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/Geo/traffic-by-country?api_key=#{api_key}&start_date=#{
        start_date
      }&end_date=#{end_date}&main_domain_only=false"

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

  defp extract_visits(%{"meta" => %{"status" => "Success"}, "visits" => visits})
       when is_list(visits) do
    {:ok, visits}
  end

  defp extract_visits(_) do
    {:error, :failed_extract}
  end

  defp extract_records(%{"records" => records}) when is_list(records) do
    {:ok, records}
  end

  defp extract_records(%{
         "meta" => %{
           "error_code" => _error_code,
           "error_message" => error_message,
           "status" => "Error"
         }
       }) do
    {:error, error_message}
  end

  defp post_process_call(%HTTPoison.Response{body: body, status_code: 200}) do
    {:ok, body}
  end

  defp post_process_call(%HTTPoison.Response{body: body, status_code: status}) do
    {:error, "HTTP #{status} : #{body}"}
  end

  defp post_process_json_body(json_body) when is_binary(json_body) do
    Jason.decode(json_body)
  end

  defp get_api_key do
    System.get_env("SIMILAR_WEB_API_TOKEN")
  end

  #
  # From a Date, get the first day of same month as date.
  defp get_first_of_month(date) do
    Date.new(date.year, date.month, 1)
  end
end
