defmodule JumpTickets.IntegrationRequestTest do
  use ExUnit.Case, async: true

  alias JumpTickets.Ticket
  alias JumpTickets.IntegrationRequest
  alias JumpTickets.Integration.Request
  alias JumpTickets.Integration.Step

  import Mock

  # Initialize mocks
  setup do
    conversation_id = "conv_#{:rand.uniform(1000)}"

    %{conversation_id: conversation_id}
  end

  describe "new/1" do
    test "creates a new integration request with all required steps", %{
      conversation_id: conversation_id
    } do
      request =
        IntegrationRequest.new(%{
          conversation_id: conversation_id,
          message_body: "What is happening?"
        })

      # Check basic properties
      assert request.intercom_conversation_id == conversation_id
      assert request.status == :pending
      assert String.starts_with?(request.id, "INT-")
      assert %DateTime{} = request.created_at
      assert %DateTime{} = request.updated_at

      # Check steps initialization
      step_types = [
        :check_existing_tickets,
        :ai_analysis,
        :create_or_update_notion_ticket,
        :maybe_create_slack_channel,
        :maybe_update_notion_with_slack,
        :add_intercom_users_to_slack
      ]

      Enum.each(step_types, fn type ->
        assert Map.has_key?(request.steps, type)
        step = request.steps[type]
        assert step.type == type
        assert step.status == :pending
        assert is_nil(step.started_at)
        assert is_nil(step.completed_at)
        assert is_nil(step.error)
        assert is_nil(step.result)
      end)
    end
  end

  describe "run/1" do
    test "runs all steps in sequence when all succeed", %{conversation_id: conversation_id} do
      request =
        IntegrationRequest.new(%{
          conversation_id: "2",
          conversation_url: "https://test.com",
          message_body: "What is happening?"
        })

      # Run the request

      result = IntegrationRequest.run(request)
      dbg(result)

      # with_mock(JumpTickets.External.LLM,
      #   find_or_create_ticket: fn _, _, _ ->
      #     {:ok, {:new, %Ticket{title: "This is the end.."}}}
      #   end
      # ) do
      #   # # Check overall request status
      #   # assert result.status == :completed

      #   # # Verify all steps were completed
      #   # Enum.each(result.steps, fn {_type, step} ->
      #   #   assert step.status == :completed
      #   #   assert %DateTime{} = step.started_at
      #   #   assert %DateTime{} = step.completed_at
      #   # end)
      # end
    end

    test "handles existing ticket with new conversation" do
      request = %JumpTickets.IntegrationRequest.Request{
        id: nil,
        intercom_conversation_id: "2",
        intercom_conversation_url: "https://new-test.example.com",
        message_body: "What is happening?",
        status: :failed,
        steps: %{
          check_existing_tickets: %JumpTickets.IntegrationRequest.Step{
            type: :check_existing_tickets,
            status: :completed,
            started_at: ~U[2025-03-16 18:16:13.845786Z],
            completed_at: ~U[2025-03-16 18:16:14.641125Z],
            error: nil,
            result: [
              %JumpTickets.Ticket{
                id: nil,
                notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
                notion_url:
                  "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
                ticket_id: "JMP-29",
                title: "Test Conversation - WhatsApp Channel Setup Demonstration",
                intercom_conversations: "https://test.com",
                summary: nil,
                slack_channel:
                  "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
              }
            ]
          },
          ai_analysis: %JumpTickets.IntegrationRequest.Step{
            type: :ai_analysis,
            status: :completed,
            started_at: ~U[2025-03-16 18:16:14.641136Z],
            completed_at: ~U[2025-03-16 18:16:21.214706Z],
            error: nil,
            result:
              {:existing,
               %JumpTickets.Ticket{
                 id: nil,
                 notion_id: "1b8d3c1b-90d3-81ab-abae-f453c9ef24cc",
                 notion_url:
                   "https://www.notion.so/Test-Conversation-WhatsApp-Channel-Setup-Demonstration-1b8d3c1b90d381ababaef453c9ef24cc",
                 ticket_id: "JMP-29",
                 title: "Test Conversation - WhatsApp Channel Setup Demonstration",
                 intercom_conversations: "https://test.com",
                 summary: nil,
                 slack_channel:
                   "https://app.slack.com/client/T08HPMYC8G6/C08J8FYMNQH?entry_point=nav_menu"
               }}
          },
          create_or_update_notion_ticket: %JumpTickets.IntegrationRequest.Step{
            type: :create_or_update_notion_ticket,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          },
          maybe_create_slack_channel: %JumpTickets.IntegrationRequest.Step{
            type: :maybe_create_slack_channel,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          },
          maybe_update_notion_with_slack: %JumpTickets.IntegrationRequest.Step{
            type: :maybe_update_notion_with_slack,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          },
          add_intercom_users_to_slack: %JumpTickets.IntegrationRequest.Step{
            type: :add_intercom_users_to_slack,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          }
        },
        created_at: ~U[2025-03-16 18:16:13.845205Z],
        updated_at: ~U[2025-03-16 18:16:21.217668Z],
        context: %{}
      }

      result = IntegrationRequest.run(request)
      dbg(result)
    end

    test "runs slack integration sucessfully" do
      request = %JumpTickets.IntegrationRequest.Request{
        id: nil,
        intercom_conversation_id: "2",
        intercom_conversation_url: "https://test.com",
        message_body: "What is happening?",
        status: :pending,
        steps: %{
          check_existing_tickets: %JumpTickets.IntegrationRequest.Step{
            type: :check_existing_tickets,
            status: :completed,
            started_at: ~U[2025-03-16 15:56:07.090280Z],
            completed_at: ~U[2025-03-16 15:56:07.886964Z],
            error: nil,
            result: []
          },
          ai_analysis: %JumpTickets.IntegrationRequest.Step{
            type: :ai_analysis,
            status: :completed,
            started_at: ~U[2025-03-16 15:56:07.887008Z],
            completed_at: ~U[2025-03-16 15:56:24.656707Z],
            error: nil,
            result:
              {:new,
               %{
                 title: "Sample Conversation Demo: WhatsApp/Social Channel Setup Verification",
                 summary:
                   "A test conversation was initiated to demonstrate how customer support interactions might appear when using WhatsApp, Instagram, or Facebook messaging channels. The conversation appears to be a system demonstration rather than an actual customer support issue. \n\nThe sample conversation includes:\n- An uploaded image (type/content not specified)\n- A descriptive message about channel integration\n- A reference to setting up communication channels\n- A brief agent response that seems to be checking system functionality\n\nWhile this appears to be a simulated scenario for testing or demonstration purposes, it raises potential questions about:\n1. Channel integration readiness\n2. Message routing capabilities\n3. System communication flow\n4. Agent response protocols\n\nRecommended actions:\n- Verify channel setup configurations\n- Test message routing across different social media platforms\n- Confirm agent interface and response mechanisms\n- Ensure proper image/attachment handling\n\nNo specific technical issue is evident, but this interaction serves as a potential test case for support channel integration testing.",
                 slug: "whatsapp-social-channel-demo"
               }}
          },
          create_or_update_notion_ticket: %JumpTickets.IntegrationRequest.Step{
            type: :create_or_update_notion_ticket,
            status: :completed,
            started_at: ~U[2025-03-16 15:56:24.656768Z],
            completed_at: ~U[2025-03-16 15:56:25.170938Z],
            error: nil,
            result: %JumpTickets.Ticket{
              id: nil,
              notion_id: "1b8d3c1b-90d3-81c3-b329-dfa72912e87c",
              ticket_id: "JMP-26",
              title: "Sample Conversation Demo: WhatsApp/Social Channel Setup Verification",
              intercom_conversations: "https://test.com",
              summary: nil,
              slack_channel: nil
            }
          },
          maybe_create_slack_channel: %JumpTickets.IntegrationRequest.Step{
            type: :maybe_create_slack_channel,
            status: :pending,
            started_at: ~U[2025-03-16 15:56:25.170967Z],
            completed_at: ~U[2025-03-16 15:56:25.170970Z],
            error: nil,
            result: nil
          },
          maybe_update_notion_with_slack: %JumpTickets.IntegrationRequest.Step{
            type: :maybe_update_notion_with_slack,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          },
          add_intercom_users_to_slack: %JumpTickets.IntegrationRequest.Step{
            type: :add_intercom_users_to_slack,
            status: :pending,
            started_at: nil,
            completed_at: nil,
            error: nil,
            result: nil
          }
        },
        created_at: ~U[2025-03-16 15:56:07.089602Z],
        updated_at: ~U[2025-03-16 15:56:25.170973Z],
        context: %{}
      }

      result = IntegrationRequest.run(request)
      dbg(result)
    end

    test "stops processing when a step fails", %{conversation_id: conversation_id} do
      request = IntegrationRequest.new(conversation_id)

      # Make the first step succeed but second step fail
      MockNotionIntegration.set_response({:ok, %{tickets: []}})
      MockAIIntegration.set_response({:error, "AI analysis failed"})

      # Run the request
      result = IntegrationRequest.run(request)

      # Check overall request status
      assert result.status == :failed

      # First step should be completed
      first_step = result.steps[:check_existing_tickets]
      assert first_step.status == :completed
      assert %DateTime{} = first_step.completed_at

      # Second step should be failed
      second_step = result.steps[:ai_analysis]
      assert second_step.status == :failed
      assert second_step.error == "AI analysis failed"

      # Later steps should still be pending
      remaining_steps = [
        :create_or_update_notion_ticket,
        :maybe_create_slack_channel,
        :maybe_update_notion_with_slack,
        :add_intercom_users_to_slack
      ]

      Enum.each(remaining_steps, fn type ->
        step = result.steps[type]
        assert step.status == :pending
        assert is_nil(step.started_at)
      end)
    end
  end

  describe "retry_step/2" do
    test "resets and retries from a specific step", %{conversation_id: conversation_id} do
      # Create a request with some completed and failed steps
      request = IntegrationRequest.new(conversation_id)

      # First run with a failure in ai_analysis
      MockNotionIntegration.set_response({:ok, %{tickets: []}})
      MockAIIntegration.set_response({:error, "AI analysis failed"})

      failed_request = IntegrationRequest.run(request)
      assert failed_request.status == :failed
      assert failed_request.steps[:ai_analysis].status == :failed

      # Now fix the AI step and retry from there
      MockAIIntegration.set_response({:ok, %{summary: "Fixed AI analysis"}})

      retried_request = IntegrationRequest.retry_step(failed_request, :ai_analysis)

      # Check if the retry worked
      assert retried_request.status == :completed
      assert retried_request.steps[:check_existing_tickets].status == :completed
      assert retried_request.steps[:ai_analysis].status == :completed
      assert retried_request.steps[:ai_analysis].result == %{summary: "Fixed AI analysis"}

      # Previous steps should maintain their results
      assert retried_request.steps[:check_existing_tickets].result ==
               failed_request.steps[:check_existing_tickets].result
    end
  end

  describe "retry_all/1" do
    test "resets and retries the entire request", %{conversation_id: conversation_id} do
      # Create a request with some completed and failed steps
      request = IntegrationRequest.new(conversation_id)

      # First run with a failure
      MockNotionIntegration.set_response({:ok, %{tickets: []}})
      MockAIIntegration.set_response({:error, "AI analysis failed"})

      failed_request = IntegrationRequest.run(request)
      assert failed_request.status == :failed

      # Now fix all steps and retry everything
      MockNotionIntegration.set_response({:ok, %{tickets: ["new_ticket"]}})
      MockAIIntegration.set_response({:ok, %{summary: "New AI analysis"}})

      retried_request = IntegrationRequest.retry_all(failed_request)

      # Check if the retry worked
      assert retried_request.status == :completed

      # Results should reflect new runs
      assert retried_request.steps[:check_existing_tickets].result == %{tickets: ["new_ticket"]}
      assert retried_request.steps[:ai_analysis].status == :completed
      assert retried_request.steps[:ai_analysis].result == %{summary: "New AI analysis"}
    end
  end
end
