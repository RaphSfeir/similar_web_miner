defmodule SimilarWebMiner do
  alias SimilarWebMiner.Geography
  alias SimilarWebMiner.Traffic

  @moduledoc """
  Client for calls to the Similar Web API, regarding geography repartition (for now).
  """
  @api_uri "https://api.similarweb.com/v1/website"
  @api_root "https://api.similarweb.com"

  @doc """
  Gets remaining hits, allowed country filters and available time periods for your account.

  This endpoint does not cost any hits.
  """
  def capabilities() do
    api_key = get_api_key()

    url = "#{@api_root}/capabilities?api_key=#{api_key}"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, response} <- post_process_json_body(json_body) do
      response
    end
  end

  @doc """
  get the last 6 months with monthly granularity
  """
  def total_visits_last_months(domain) do
    today = Date.utc_today()
    end_date = today |> get_end_date_from_today()

    start_date = get_first_of_month(Date.add(today, -6 * 30))
    total_visits(domain, start_date, end_date, "monthly")
  end

  def lead_enrichment_traffic_stats_last_months(domain) do
    today = Date.utc_today()
    end_date = today |> get_end_date_from_today()

    start_date = get_first_of_month(Date.add(today, -6 * 30))
    lead_enrichment_traffic_stats(domain, start_date, end_date)
  end

  def lead_enrichment_last_months(domain) do
    today = Date.utc_today()
    end_date = today |> get_end_date_from_today()

    start_date = get_first_of_month(Date.add(today, -6 * 30))
    lead_enrichment(domain, start_date, end_date)
  end

  def lead_enrichment_traffic_stats(
        domain,
        start_date \\ "2021-03",
        end_date \\ "2021-05"
      ) do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/lead-enrichment/all?api_key=#{api_key}&start_date=#{start_date}&end_date=#{
        end_date
      }&country=world&main_domain_only=false&format=json"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body),
         {:ok, visits} <- extract_visits(body),
         {:ok, visitors} <- extract_visitors(body),
         monthly_visits <- visits |> Enum.map(&Traffic.extract_values/1),
         visitors <- visitors |> Enum.map(&Traffic.extract_values/1) do
      %{total_visits: monthly_visits, unique_visitors: visitors}
    else
      err -> {:error, err}
    end
  end

  def lead_enrichment(
        domain,
        start_date \\ "2021-03",
        end_date \\ "2021-05"
      ) do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/lead-enrichment/all?api_key=#{api_key}&start_date=#{start_date}&end_date=#{
        end_date
      }&country=world&main_domain_only=false&format=json"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body) do
      {:ok, body |> Map.put("start_date", start_date) |> Map.put("end_date", end_date)}
    else
      err -> {:error, err}
    end
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

  def total_desktop_visitors(
        domain,
        start_date \\ "2021-03",
        end_date \\ "2021-05",
        granularity \\ "monthly"
      ) do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/unique-visitors/desktop_unique_visitors?api_key=#{api_key}&start_date=#{
        start_date
      }&end_date=#{end_date}&country=world&granularity=#{granularity}&main_domain_only=false&format=json"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body),
         {:ok, records} <- extract_visitors(body),
         monthly_visits <- Traffic.process_result_visitors(records) do
      monthly_visits
    else
      err -> {:error, err}
    end
  end

  def total_mobile_visitors(
        domain,
        start_date \\ "2021-03",
        end_date \\ "2021-05",
        granularity \\ "monthly"
      ) do
    clean_domain = SimilarWebMiner.URL.host(domain)
    api_key = get_api_key()

    url =
      "#{@api_uri}/#{clean_domain}/unique-visitors/mobileweb_unique_visitors?api_key=#{api_key}&start_date=#{
        start_date
      }&end_date=#{end_date}&country=world&granularity=#{granularity}&main_domain_only=false&format=json"

    with {:ok, call_result} <- HTTPoison.get(url),
         {:ok, json_body} <- post_process_call(call_result),
         {:ok, body} <- post_process_json_body(json_body),
         {:ok, records} <- extract_visitors(body),
         monthly_visits <- Traffic.process_result_visitors(records) do
      monthly_visits
    else
      err -> {:error, err}
    end
  end

  @spec geography_repartition(any, any, any) :: list | {:error, {:error, any}}
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

  defp extract_visitors(%{
         "meta" => %{"status" => "Success"},
         "unique_visitors" => unique_visitors
       })
       when is_list(unique_visitors) do
    {:ok, unique_visitors}
  end

  defp extract_visitors(_), do: {:error, :failed_extract}

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

  defp post_process_call(%HTTPoison.Response{body: body, status_code: 200}), do: {:ok, body}

  defp post_process_call(%HTTPoison.Response{body: body, status_code: status}) do
    {:error, "HTTP #{status} : #{body}"}
  end

  defp post_process_json_body(json_body) when is_binary(json_body) do
    Jason.decode(json_body)
  end

  defp get_api_key do
    System.get_env("SIMILAR_WEB_API_TOKEN")
  end

  def get_end_date_from_today(today) do
    day_of_month = today.day

    if day_of_month < 15 do
      get_first_of_month(today |> Timex.shift(months: -2))
    else
      get_first_of_month(today |> Timex.shift(months: -1))
    end
  end

  #
  # From a Date, get the first day of same month as date.
  defp get_first_of_month(date) do
    {:ok, d} = Date.new(date.year, date.month, 1)
    d
  end
end
