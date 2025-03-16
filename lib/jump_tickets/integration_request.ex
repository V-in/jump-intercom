defmodule JumpTickets.IntegrationRequest do
  alias JumpTickets.IntegrationRequest.Coordinator

  def create_integration_request(
        %{
          conversation_id: conversation_id,
          conversation_url: conversation_url,
          message_body: message_body
        } = params
      ) do
    Coordinator.create_request(params)
  end

  def list_integration_requests() do
    Coordinator.list_requests()
  end

  def retry_step(request_id, step) do
    Coordinator.retry_step(request_id, step)
  end
end
