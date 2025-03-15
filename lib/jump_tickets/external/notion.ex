defmodule JumpTickets.External.Notion do
  alias JumpTickets.Ticket
  alias Notionex
  alias Notionex.API

  @db_id "1b7d3c1b90d3806a8e42ef7d903589cb"

  def query_db(db_id \\ @db_id) do
    result =
      Notionex.API.query_database(%{database_id: db_id, page_size: 20})
      |> __MODULE__.Parser.parse_response()

    result
  end

  def create_ticket(%Ticket{} = ticket, db_id \\ @db_id) do
    properties = %{
      "Id" => %{
        title: [%{text: %{content: ticket.ticket_id}}]
      },
      "Title" => %{
        rich_text: [%{text: %{content: ticket.title}}]
      },
      "Intercom Conversations" => %{
        rich_text: [%{text: %{content: ticket.intercom_conversations}}]
      },
      "children" => %{
        rich_text: [%{text: %{content: ticket.summary}}]
      },
      "Slack Channel" => %{
        rich_text: [%{text: %{content: ticket.slack_channel}}]
      }
    }

    Notionex.API.create_page(%{
      parent: %{database_id: db_id},
      properties: properties
    })
  end
end

defmodule JumpTickets.External.Notion.Parser do
  @moduledoc false
  alias JumpTickets.Ticket

  require Logger

  def parse_response(response) do
    case response do
      %Notionex.Object.List{results: results} ->
        Enum.map(results, &parse_ticket/1)

      _ ->
        {:error, "Invalid response format"}
    end
  end

  defp parse_ticket(page) do
    properties = page["properties"]

    %Ticket{
      ticket_id: extract_title(properties["Id"]),
      title: extract_rich_text(properties["Title"]),
      intercom_conversations: extract_rich_text(properties["Intercom Conversations"]),
      summary: extract_rich_text(properties["children"]),
      slack_channel: extract_rich_text(properties["Slack Channel"])
    }
  end

  # Extract plain text from a title property
  defp extract_title(%{"title" => title}) do
    case title do
      [%{"plain_text" => text} | _] -> text
      _ -> nil
    end
  end

  defp extract_title(_), do: nil

  # Extract plain text from a rich_text property
  defp extract_rich_text(%{"rich_text" => rich_text}) do
    case rich_text do
      [%{"plain_text" => text} | _] -> text
      _ -> nil
    end
  end

  defp extract_rich_text(_), do: nil
end
