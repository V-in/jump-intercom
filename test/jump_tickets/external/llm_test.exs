defmodule JumpTickets.External.LlmTest do
  @moduledoc false

  use ExUnit.Case
  import Mock
  alias JumpTickets.External.LLM

  describe "format_conversation/1" do
    test "correctly formats a conversation" do
      conversation = %{
        messages: [
          %{text: "Hello, I'm having an issue", author: "Jane Smith (user)"},
          %{text: "Can you describe the problem?", author: "Support Agent (admin)"}
        ]
      }

      expected =
        "Customer (Jane Smith): Hello, I'm having an issue\n\nAgent (Support Agent): Can you describe the problem?"

      assert LLM.format_conversation(conversation) == expected
    end
  end

  describe "format_existing_tickets/1" do
    test "formats tickets into readable strings" do
      tickets = [
        %JumpTickets.Ticket{ticket_id: "JMP-001", title: "Login Issues"},
        %JumpTickets.Ticket{ticket_id: "JMP-002", title: "API Integration Failure"}
      ]

      expected = "ID: JMP-001 | Title: Login Issues\nID: JMP-002 | Title: API Integration Failure"

      assert LLM.format_existing_tickets(tickets) == expected
    end
  end

  describe "extract_json_string/1" do
    test "extracts JSON from code blocks" do
      text = """
      Here's my analysis:

      ```json
      {"decision": "new", "reasoning": "No matching tickets found"}
      ```

      Hope that helps!
      """

      expected = ~s({"decision": "new", "reasoning": "No matching tickets found"})

      assert LLM.extract_json_string(text) == expected
    end

    test "extracts JSON without code blocks" do
      text = """
      Here's my analysis:

      {"decision": "existing", "ticket_id": "JMP-001", "reasoning": "Matches first ticket"}

      Hope that helps!
      """

      expected =
        ~s({"decision": "existing", "ticket_id": "JMP-001", "reasoning": "Matches first ticket"})

      assert String.trim(LLM.extract_json_string(text)) == String.trim(expected)
    end
  end

  describe "fallback_parse_json/1" do
    test "extracts fields from malformed JSON" do
      text = """
      I think this should be a new ticket because there's nothing similar.

      "decision": "new",
      "reasoning": "No existing tickets match this conversation"
      """

      expected = %{"decision" => "new"}

      assert LLM.fallback_parse_json(text) == expected
    end
  end

  describe "find_or_create_ticket/3" do
    test "returns existing ticket when match is found" do
      existing_tickets = [
        %JumpTickets.Ticket{ticket_id: "JMP-001", title: "Login Issues"},
        %JumpTickets.Ticket{ticket_id: "JMP-002", title: "API Integration Failure"}
      ]

      conversation = %{
        messages: [
          %{text: "I can't log in", author: "Jane Smith (user)"},
          %{text: "What error do you see?", author: "Support Agent (admin)"}
        ]
      }

      message_body = "I can't log in"

      result =
        JumpTickets.External.LLM.find_or_create_ticket(
          existing_tickets,
          message_body,
          conversation,
          # Mock the Claude API call
          fn prompt -> {:ok, %{"decision" => "existing", "ticket_id" => "JMP-001"}} end
        )

      assert result == {:existing, Enum.at(existing_tickets, 0)}
    end
  end
end
