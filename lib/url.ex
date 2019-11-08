defmodule SimilarWebMiner.URL do

  def host(url = "http" <> _) do
    url 
    |> extract_host_from_cleaned()
  end

  def host(url_no_http) do
    "http://#{url_no_http}"
    |> extract_host_from_cleaned()
  end

  defp extract_host_from_cleaned(clean_url) do
    %URI {
      host: host
    } = URI.parse(clean_url)
    host
    |> String.replace_leading("www.", "")
  end
end
