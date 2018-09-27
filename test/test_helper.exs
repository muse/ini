defmodule TestHelper do
  @moduledoc false

  @spec init :: :ok
  def init do
    ExUnit.start()
  end

end

TestHelper.init
