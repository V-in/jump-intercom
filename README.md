# JumpTickets

## Integration Logic

Sample request

```elixir
%JumpTickets.IntegrationRequest.Request{
  id: nil,
  intercom_conversation_id: "2",
  intercom_conversation_url: "https://new-test.example.com",
  message_body: "What is happening?",
  status: :completed,
  steps: %{
    check_existing_tickets: %JumpTickets.IntegrationRequest.Step{
      type: :check_existing_tickets,
      status: :completed,
      started_at: ~U[2025-03-16 18:16:13.845786Z],
      completed_at: ~U[2025-03-16 18:16:14.641125Z],
      error: nil,
      result: [
        %JumpTickets.Ticket{
          __meta__: #Ecto.Schema.Metadata<:built, "tickets">,
          id: nil,
          notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
          notion_url: "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
          ticket_id: "JMP-29",
          title: "Test Conversation - WhatsApp Channel Setup Demonstration",
          intercom_conversations: "https://test.com",
          summary: nil,
          slack_channel: "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
        }
      ]
    },
    ai_analysis: %JumpTickets.IntegrationRequest.Step{
      type: :ai_analysis,
      status: :completed,
      started_at: ~U[2025-03-16 18:16:14.641136Z],
      completed_at: ~U[2025-03-16 18:16:21.214706Z],
      error: nil,
      result: {:existing,
       %JumpTickets.Ticket{
         __meta__: #Ecto.Schema.Metadata<:built, "tickets">,
         id: nil,
         notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
         notion_url: "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
         ticket_id: "JMP-29",
         title: "Test Conversation - WhatsApp Channel Setup Demonstration",
         intercom_conversations: "https://test.com",
         summary: nil,
         slack_channel: "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
       }}
    },
    create_or_update_notion_ticket: %JumpTickets.IntegrationRequest.Step{
      type: :create_or_update_notion_ticket,
      status: :completed,
      started_at: ~U[2025-03-16 19:37:43.331492Z],
      completed_at: ~U[2025-03-16 19:37:44.668251Z],
      error: nil,
      result: %JumpTickets.Ticket{
        __meta__: #Ecto.Schema.Metadata<:built, "tickets">,
        id: nil,
        notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
        notion_url: "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
        ticket_id: "JMP-29",
        title: "Test Conversation - WhatsApp Channel Setup Demonstration",
        intercom_conversations: "https://new-test.example.com,https://test.com",
        summary: nil,
        slack_channel: "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
      }
    },
    maybe_create_slack_channel: %JumpTickets.IntegrationRequest.Step{
      type: :maybe_create_slack_channel,
      status: :completed,
      started_at: ~U[2025-03-16 19:37:44.668263Z],
      completed_at: ~U[2025-03-16 19:37:44.668287Z],
      error: nil,
      result: %{
        url: "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu",
        channel_id: "C08J8FYMNQH"
      }
    },
    maybe_update_notion_with_slack: %JumpTickets.IntegrationRequest.Step{
      type: :maybe_update_notion_with_slack,
      status: :completed,
      started_at: ~U[2025-03-16 19:37:44.668292Z],
      completed_at: ~U[2025-03-16 19:37:45.421927Z],
      error: nil,
      result: %JumpTickets.Ticket{
        __meta__: #Ecto.Schema.Metadata<:built, "tickets">,
        id: nil,
        notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
        notion_url: "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
        ticket_id: "JMP-29",
        title: "Test Conversation - WhatsApp Channel Setup Demonstration",
        intercom_conversations: "https://new-test.example.com,https://test.com",
        summary: nil,
        slack_channel: "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
      }
    },
    add_intercom_users_to_slack: %JumpTickets.IntegrationRequest.Step{
      type: :add_intercom_users_to_slack,
      status: :completed,
      started_at: ~U[2025-03-16 19:37:45.421939Z],
      completed_at: ~U[2025-03-16 19:37:47.775819Z],
      error: nil,
      result: nil
    }
  },
  created_at: ~U[2025-03-16 18:16:13.845205Z],
  updated_at: ~U[2025-03-16 19:37:47.775832Z],
  context: %{}
}
```

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
