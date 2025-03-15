defmodule JumpTickets.External.Notion.ParserTest do
  use ExUnit.Case, async: true
  alias JumpTickets.External.Notion.Parser
  alias JumpTickets.Ticket
  alias Notionex.Object.List

  describe "parse_response/1" do
    test "successfully parses a valid Notion response" do
      response = %List{
        results: [
          %{
            "properties" => %{
              "Id" => %{
                "title" => [
                  %{"plain_text" => "TICKET-123"}
                ]
              },
              "Title" => %{
                "rich_text" => [
                  %{"plain_text" => "Test Ticket"}
                ]
              },
              "Intercom Conversations" => %{
                "rich_text" => [
                  %{"plain_text" => "conv-123"}
                ]
              },
              "children" => %{
                "rich_text" => [
                  %{"plain_text" => "Test summary"}
                ]
              },
              "Slack Channel" => %{
                "rich_text" => [
                  %{"plain_text" => "#test-channel"}
                ]
              }
            }
          }
        ]
      }

      [result] = Parser.parse_response(response)

      assert %Ticket{} = result
      assert result.ticket_id == "TICKET-123"
      assert result.title == "Test Ticket"
      assert result.intercom_conversations == "conv-123"
      assert result.summary == "Test summary"
      assert result.slack_channel == "#test-channel"
    end

    test "handles empty response list" do
      response = %List{results: []}
      assert [] = Parser.parse_response(response)
    end

    test "returns error for invalid response format" do
      invalid_response = %{foo: "bar"}
      assert {:error, "Invalid response format"} = Parser.parse_response(invalid_response)
    end

    test "handles missing properties" do
      response = %List{
        results: [
          %{
            "properties" => %{
              "Id" => %{
                "title" => []
              },
              "Title" => %{
                "rich_text" => []
              }
            }
          }
        ]
      }

      [result] = Parser.parse_response(response)

      assert %Ticket{} = result
      assert result.ticket_id == nil
      assert result.title == nil
      assert result.intercom_conversations == nil
      assert result.summary == nil
      assert result.slack_channel == nil
    end

    test "handles malformed property structures" do
      response = %List{
        results: [
          %{
            "properties" => %{
              "Id" => "invalid",
              "Title" => 123,
              "Intercom Conversations" => nil,
              "children" => %{},
              "Slack Channel" => []
            }
          }
        ]
      }

      [result] = Parser.parse_response(response)

      assert %Ticket{} = result
      assert result.ticket_id == nil
      assert result.title == nil
      assert result.intercom_conversations == nil
      assert result.summary == nil
      assert result.slack_channel == nil
    end

    test "parses multiple tickets" do
      response = %List{
        results: [
          %{
            "archived" => false,
            "cover" => nil,
            "created_by" => %{
              "id" => "936c8b81-c8b3-4fd7-804b-2abe165b4a65",
              "object" => "user"
            },
            "created_time" => "2025-03-15T18:48:00.000Z",
            "icon" => nil,
            "id" => "1b7d3c1b-90d3-8152-959c-d6c243b4d4fa",
            "in_trash" => false,
            "last_edited_by" => %{
              "id" => "936c8b81-c8b3-4fd7-804b-2abe165b4a65",
              "object" => "user"
            },
            "last_edited_time" => "2025-03-15T18:48:00.000Z",
            "object" => "page",
            "parent" => %{
              "database_id" => "1b7d3c1b-90d3-806a-8e42-ef7d903589cb",
              "type" => "database_id"
            },
            "properties" => %{
              "Id" => %{
                "id" => "title",
                "title" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "2",
                    "text" => %{"content" => "2", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "title"
              },
              "Intercom Conversations" => %{
                "id" => "DRly",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "Test",
                    "text" => %{"content" => "Test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "Slack Channel" => %{
                "id" => "b~en",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "Test",
                    "text" => %{"content" => "Test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "Title" => %{
                "id" => "Dn%5ED",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "This is a test",
                    "text" => %{"content" => "This is a test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "children" => %{
                "id" => "rzNB",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "This is also a test dude",
                    "text" => %{
                      "content" => "This is also a test dude",
                      "link" => nil
                    },
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              }
            },
            "public_url" => nil,
            "url" => "https://www.notion.so/2-1b7d3c1b90d38152959cd6c243b4d4fa"
          },
          %{
            "archived" => false,
            "cover" => nil,
            "created_by" => %{
              "id" => "d8b149e2-2698-49ac-8ff7-456b53c415f0",
              "object" => "user"
            },
            "created_time" => "2025-03-15T17:13:00.000Z",
            "icon" => nil,
            "id" => "1b7d3c1b-90d3-8008-8a08-faafb38ca31a",
            "in_trash" => false,
            "last_edited_by" => %{
              "id" => "d8b149e2-2698-49ac-8ff7-456b53c415f0",
              "object" => "user"
            },
            "last_edited_time" => "2025-03-15T17:14:00.000Z",
            "object" => "page",
            "parent" => %{
              "database_id" => "1b7d3c1b-90d3-806a-8e42-ef7d903589cb",
              "type" => "database_id"
            },
            "properties" => %{
              "Id" => %{
                "id" => "title",
                "title" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "1",
                    "text" => %{"content" => "1", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "title"
              },
              "Intercom Conversations" => %{
                "id" => "DRly",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "Test",
                    "text" => %{"content" => "Test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "Slack Channel" => %{
                "id" => "b~en",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "Test",
                    "text" => %{"content" => "Test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "Title" => %{
                "id" => "Dn%5ED",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "This is a test",
                    "text" => %{"content" => "This is a test", "link" => nil},
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              },
              "children" => %{
                "id" => "rzNB",
                "rich_text" => [
                  %{
                    "annotations" => %{
                      "bold" => false,
                      "code" => false,
                      "color" => "default",
                      "italic" => false,
                      "strikethrough" => false,
                      "underline" => false
                    },
                    "href" => nil,
                    "plain_text" => "This is also a test dude",
                    "text" => %{
                      "content" => "This is also a test dude",
                      "link" => nil
                    },
                    "type" => "text"
                  }
                ],
                "type" => "rich_text"
              }
            },
            "public_url" => nil,
            "url" => "https://www.notion.so/1-1b7d3c1b90d380088a08faafb38ca31a"
          }
        ],
        has_more: false,
        next_cursor: nil,
        page_or_database: %{}
      }

      result = Parser.parse_response(response)
      [first, second] = result

      assert first.ticket_id == "2"
      assert first.title == "This is a test"
      assert second.ticket_id == "1"
      assert second.title == "This is a test"
    end
  end

  describe "extract_title/1" do
    test "handles nil input" do
      result =
        Parser.parse_response(%List{
          results: [
            %{
              "properties" => %{
                "Id" => nil,
                "Title" => %{"rich_text" => [%{"plain_text" => "Test"}]}
              }
            }
          ]
        })

      [ticket] = result
      assert ticket.ticket_id == nil
    end
  end

  describe "extract_rich_text/1" do
    test "handles nil input" do
      result =
        Parser.parse_response(%List{
          results: [
            %{
              "properties" => %{
                "Id" => %{"title" => [%{"plain_text" => "TEST-1"}]},
                "Title" => nil
              }
            }
          ]
        })

      [ticket] = result
      assert ticket.title == nil
    end
  end
end
