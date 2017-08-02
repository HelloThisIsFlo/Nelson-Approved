defmodule NelsonApproved.ArtificialIntelligence.Network do
  use HTTPotion.Base

  @timeout 1500

  defmodule Behaviour do
    @type word :: String.t
    @callback semantic_relatedness(word, word) :: number | :error
  end

  @behaviour Behaviour
  @mashape_key Application.fetch_env!(:nelson_approved, :mashape_key)

  # TODO: Actually the remaining calls are available on the response header =
  # => Parse from there, and remove from database

  @spec semantic_relatedness(String.t, String.t) :: number | :error
  def semantic_relatedness(word1, word2) do
    "https://amtera.p.mashape.com/relatedness/en"
    |> post([body: body(word1, word2), timeout: @timeout])
    |> Map.get(:body, "")
    |> Poison.decode
    |> extract_result
    |> Map.get("v", :error)
    |> map_zero_or_nil_to_error()
  end
  defp extract_result({:ok, result}), do: result
  defp extract_result({:error, _}),   do: %{}
  defp map_zero_or_nil_to_error(0.0), do: :error
  defp map_zero_or_nil_to_error(nil), do: :error
  defp map_zero_or_nil_to_error(val), do: val

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:"X-Mashape-Key", @mashape_key)
    |> Keyword.put(:"Content-Type", "application/json")
    |> Keyword.put(:"Accept", "application/json")
  end

  defp body(word1, word2) do
    %{"t1": word1, "t2": word2} |> Poison.encode!
  end

end
