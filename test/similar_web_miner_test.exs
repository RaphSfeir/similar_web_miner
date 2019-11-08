defmodule SimilarWebMinerTest do
  use ExUnit.Case
  doctest SimilarWebMiner
  doctest SimilarWebMiner.Geography

  @domain "gamekult.fr"
  @no_protocol_url "www.gamekult.fr/test-dude/"
  @https_protocol_url "https://www.gamekult.fr/test-dude"
  @http_protocol_url "http://www.gamekult.fr/test-dude"

  @raw_geography_info_list [
    %{
      "country" => 250,
      "share" => 0.7851,
      "visits" => 2_540_038,
      "pages_per_visit" => 3.4505905958407035,
      "average_time" => 199.01303489498287,
      "bounce_rate" => 0.51907817399543477,
      "rank" => 783
    },
    %{
      "country" => 56,
      "share" => 0.05160598056420361,
      "visits" => 166_950.17185653298,
      "pages_per_visit" => 2.2413039664465395,
      "average_time" => 110.73873531047586,
      "bounce_rate" => 0.56825305617742927,
      "rank" => 2733
    },
    %{
      "country" => 756,
      "share" => 0.046680707328691944,
      "visits" => 151_016.45246743906,
      "pages_per_visit" => 2.6792727198039596,
      "average_time" => 222.36424623084818,
      "bounce_rate" => 0.46059153298449268,
      "rank" => 3238
    },
    %{
      "country" => 124,
      "share" => 0.024245366416713564,
      "visits" => 78436.027098817867,
      "pages_per_visit" => 2.1819529247558558,
      "average_time" => 155.40197144536683,
      "bounce_rate" => 0.58110005802987841,
      "rank" => 12701
    }
  ]

  @raw_geography_info %{
    "country" => 250,
    "share" => 0.7851,
    "visits" => 2_540_038,
    "pages_per_visit" => 3.4505905958407035,
    "average_time" => 199.01303489498287,
    "bounce_rate" => 0.51907817399543477,
    "rank" => 783
  }
  test "extract geographical repartition" do
    assert SimilarWebMiner.Geography.extract_info(@raw_geography_info) == %{
             country: "France",
             country_code: 250,
             share: 0.7851,
             visits: 2_540_038,
             average_time: 199.01303489498287,
             bounce_rate: 0.5190781739954348,
             pages_per_visit: 3.4505905958407035,
             rank: 783
           }
  end

  test "extract geographical repartition list" do
    processed =
      SimilarWebMiner.Geography.process_result_list(@raw_geography_info_list)
      |> List.first()

    assert processed == %{
             country: "France",
             country_code: 250,
             share: 0.7851,
             visits: 2_540_038,
             average_time: 199.01303489498287,
             bounce_rate: 0.5190781739954348,
             pages_per_visit: 3.4505905958407035,
             rank: 783
           }
  end

  test "extract geo repartition with various url http format" do
    assert @domain == SimilarWebMiner.URL.host(@http_protocol_url)
  end

  test "extract geo repartition with various url https format" do
    assert @domain == SimilarWebMiner.URL.host(@https_protocol_url)
  end

  test "extract geo repartition with various url no protocol format" do
    assert @domain == SimilarWebMiner.URL.host(@no_protocol_url)
  end
end
