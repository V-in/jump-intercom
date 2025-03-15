defmodule JumpTicketsWeb.IntercomController do
  use JumpTicketsWeb, :controller

  # Handle GET /api/initialize
  # Canvas Kit payload for the initial view with an "Add Notion Ticket" button
  defp initial_canvas do
    %{
      canvas: %{
        content: %{
          components: [
            %{
              type: "button",
              label: "Add Notion Ticket",
              style: "primary",
              id: "add_notion_ticket",
              action: %{
                type: "submit"
              }
            }
          ]
        }
      }
    }
  end

  # Handle POST /api/initialize
  def initialize(conn, _params) do
    # Intercom calls this when the app is inserted into the inbox or a new conversation is viewed
    conn
    |> put_status(:ok)
    |> json(initial_canvas())
  end

  # Handle POST /api/submit
  def submit(conn, params) do
    # Log the incoming payload for debugging
    IO.inspect(params, label: "Intercom Submit Payload")

    # Example payload from Intercom might look like:
    # %{
    #   "component_id" => "add_notion_ticket",
    #   "conversation_id" => "12345",
    #   "app_id" => "your-intercom-app-id"
    # }

    case process_notion_ticket(params) do
      {:ok, result} ->
        # Return a confirmation canvas
        confirmation_canvas = %{
          canvas: %{
            content: %{
              components: [
                %{
                  type: "text",
                  text: "Notion ticket created: #{result.ticket_id}"
                }
              ]
            }
          }
        }

        conn
        |> put_status(:ok)
        |> json(confirmation_canvas)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: reason})
    end
  end

  # Private helper function (placeholder for Notion/Slack logic)
  defp process_notion_ticket(params) do
    # Extract conversation ID
    conversation_id = Map.get(params, "conversation_id")

    # TODO: Add logic to:
    # 1. Fetch conversation details from Intercom API
    # 2. Query Notion for existing tickets
    # 3. Use AI to decide new vs. existing ticket
    # 4. Create/update Notion ticket and Slack channel

    # For now, return a mock success response
    {:ok,
     %{
       ticket_id: "JMP-123",
       slack_channel: "#JMP-123-sync-issue",
       conversation_id: conversation_id
     }}
  end
end
