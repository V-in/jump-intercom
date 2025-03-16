defmodule JumpTicketsWeb.IntegrationRequestsLive do
  use JumpTicketsWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end
end
