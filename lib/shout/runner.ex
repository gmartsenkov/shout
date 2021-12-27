defmodule Shout.Runner do
  alias Shout.Subscription

  @spec run(list(Subscription.t()), any()) :: :ok
  def run(subscriptions, data) do
    Enum.each(subscriptions, &execute(&1, data))
  end

  @spec execute(Subscription.t(), any) :: :ok
  defp execute(%Subscription{to: fun}, data) when is_function(fun) do
    fun.(data)
  end
end
