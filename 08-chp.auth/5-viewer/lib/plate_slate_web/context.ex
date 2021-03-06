#---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
#---
defmodule PlateSlateWeb.Context do
  @behaviour Plug
  import Plug.Conn

  def data_loader() do
    DataLoader.new
    |> DataLoader.add_source(Menu, Menu.data())
  end

  def init(opts), do: opts

  def call(conn, _) do
    context =
      conn
      |> build_context
      |> Map.put(:loader, data_loader())

    put_private(conn, :absinthe, %{context: context})
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
    {:ok, data} <- PlateSlateWeb.Authentication.verify(token),
    %{} = user <- get_user(data) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end

  defp get_user(%{id: id, role: role}) do
    PlateSlate.Accounts.lookup(role, id)
  end
end
