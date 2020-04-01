defmodule SengokuWeb.AcceptanceCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias SengokuWeb.Router.Helpers, as: Routes

      import Wallaby.Query
    end
  end

  setup _tags do
    {:ok, session} = Wallaby.start_session(window_size: [width: 1280, height: 720])
    {:ok, session: session}
  end
end
