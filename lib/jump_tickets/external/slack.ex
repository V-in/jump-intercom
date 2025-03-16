defmodule JumpTickets.External.Slack do
  @moduledoc """
  Handles Slack integration functionality
  """

  require Logger
  alias HTTPoison.Response

  @slack_api_url "https://slack.com/api"

  def get_slack_token do
    Application.get_env(:jump_tickets, :slack)[:bot_token]
  end

  @doc """
  Creates a new Slack channel with the given name
  """
  def create_channel(channel_name) do
    url = "#{@slack_api_url}/conversations.create"

    # Normalize channel name (lowercase, no spaces, only alphanumeric and hyphens)
    normalized_name =
      channel_name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\-]/, "-")
      |> String.replace(~r/-+/, "-")
      |> String.trim("-")

    body =
      Jason.encode!(%{
        name: normalized_name,
        is_private: false
      })

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %Response{status_code: 200, body: "{\"ok\":false,\"error\":\"name_taken\"}"} = resp} ->
        get_channel(channel_name)

      {:ok, %Response{status_code: 200, body: response_body} = resp} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          channel = parsed["channel"]

          {:ok,
           %{
             channel_id: channel["id"],
             url:
               "https://app.slack.com/client/#{channel["context_team_id"]}/#{channel["id"]}?entry_point=nav_menu"
           }}
        else
          Logger.error("Failed to create Slack channel: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when creating Slack channel: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Sets the topic of the given channel
  """
  def set_channel_topic(channel_id, topic) do
    url = "#{@slack_api_url}/conversations.setTopic"

    body =
      Jason.encode!(%{
        channel: channel_id,
        topic: topic
      })

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          {:ok, parsed}
        else
          Logger.error("Failed to set channel topic: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when setting channel topic: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Gets all users from Slack
  """
  def get_all_users do
    url = "#{@slack_api_url}/users.list"

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          members =
            parsed["members"]
            |> Enum.map(
              &%{
                id: &1["id"],
                name: &1["real_name"],
                email: get_in(&1, ["profile", "email"])
              }
            )

          {:ok, members}
        else
          Logger.error("Failed to get Slack users: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when getting Slack users: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Invites users to a channel
  """
  def invite_users_to_channel(channel_id, user_ids) when is_list(user_ids) do
    url = "#{@slack_api_url}/conversations.invite"

    # Slack API requires at least one user and no more than 1000
    user_ids = user_ids |> Enum.uniq() |> Enum.take(1000)

    # Skip if no users to invite
    if Enum.empty?(user_ids) do
      {:ok, "No users to invite"}
    else
      body =
        Jason.encode!(%{
          channel: channel_id,
          users: Enum.join(user_ids, ",")
        })

      headers = [
        {"Authorization", "Bearer #{get_slack_token()}"},
        {"Content-Type", "application/json; charset=utf-8"}
      ]

      case HTTPoison.post(url, body, headers) do
        {:ok, %Response{status_code: 200, body: response_body}} ->
          parsed = Jason.decode!(response_body)

          if parsed["ok"] do
            {:ok, parsed}
          else
            Logger.error("Failed to invite users to channel: #{parsed["error"]}")
            {:error, parsed["error"]}
          end

        {:error, error} ->
          Logger.error("HTTP error when inviting users to channel: #{inspect(error)}")
          {:error, error}
      end
    end
  end

  @doc """
  Posts a message to a channel
  """
  def post_message(channel_id, text) do
    url = "#{@slack_api_url}/chat.postMessage"

    body =
      Jason.encode!(%{
        channel: channel_id,
        text: text
      })

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          {:ok, parsed}
        else
          Logger.error("Failed to post message: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when posting message: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Gets a channel by its name
  """
  def get_channel(channel_name) do
    url = "#{@slack_api_url}/conversations.list"

    # Normalize channel name to match Slack's format
    normalized_name =
      channel_name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\-]/, "-")
      |> String.replace(~r/-+/, "-")
      |> String.trim("-")

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    params = [
      {"types", "public_channel"},
      {"limit", "1000"}
    ]

    case HTTPoison.get(url <> "?" <> URI.encode_query(params), headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          # Find the channel with matching name
          channel =
            Enum.find(parsed["channels"], fn channel ->
              channel["name"] == normalized_name
            end)

          if channel do
            {:ok,
             %{
               channel_id: channel["id"],
               url:
                 "https://app.slack.com/client/#{channel["context_team_id"] || Application.get_env(:jump_tickets, :slack)[:team_id]}/#{channel["id"]}?entry_point=nav_menu"
             }}
          else
            {:error, :channel_not_found}
          end
        else
          Logger.error("Failed to get Slack channels: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when getting Slack channels: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Lists users in a given Slack channel.

  Returns a list of users in the format:
  %{
    id: user["id"],
    name: user["real_name"],
    email: get_in(user, ["profile", "email"])
  }
  """
  def list_channel_users(channel_id) do
    url = "#{@slack_api_url}/conversations.members"

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    params = [{"channel", channel_id}]

    case HTTPoison.get(url <> "?" <> URI.encode_query(params), headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          member_ids = parsed["members"] || []

          # Retrieve all users and filter by member IDs.
          case get_all_users() do
            {:ok, users} ->
              channel_users =
                users
                |> Enum.filter(fn user -> user[:id] in member_ids end)

              {:ok, channel_users}

            {:error, error} ->
              {:error, error}
          end
        else
          Logger.error("Failed to list channel users: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when listing channel users: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Sets the topic of the given channel
  """
  def set_topic(channel_id, topic) do
    url = "#{@slack_api_url}/conversations.setTopic"

    body =
      Jason.encode!(%{
        channel: channel_id,
        topic: topic
      })

    headers = [
      {"Authorization", "Bearer #{get_slack_token()}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %Response{status_code: 200, body: response_body}} ->
        parsed = Jason.decode!(response_body)

        if parsed["ok"] do
          {:ok, parsed}
        else
          Logger.error("Failed to set channel topic: #{parsed["error"]}")
          {:error, parsed["error"]}
        end

      {:error, error} ->
        Logger.error("HTTP error when setting channel topic: #{inspect(error)}")
        {:error, error}
    end
  end
end
