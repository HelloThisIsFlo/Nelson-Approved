defmodule NelsonApproved.AiCounterMock do
  @call_counter_limit 3000

  # Mock counter:
  # Initial value is 0, so it will always allow (unless 3000 test with same mock -_-)

  def start_mock() do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def increment_and_check_counter() do
    Agent.get_and_update(__MODULE__, fn(counter) ->
      counter = counter + 1
      allowed = counter < @call_counter_limit
      {allowed, counter}
    end)
  end

  def set_counter(val) do
    Agent.update(__MODULE__, fn(counter) ->
      val
    end)
  end

  def get_counter() do
    Agent.get(__MODULE__, fn(counter) -> counter end)
  end

end
