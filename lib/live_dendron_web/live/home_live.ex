defmodule LiveDendronWeb.HomeLive do
  use Phoenix.LiveView
  alias LiveDendron.Core
  alias LiveDendron.TeamEditor
  alias LiveDendron.TreeEditor

  def render(assigns), do: LiveDendronWeb.HomeLiveView.render("main.html", assigns)

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:teams, Core.list_teams())
      |> assign(:team_editor, nil)

    {:ok, socket}
  end

  @doc false
  def handle_event("select_team", "", socket), do: assign(socket, :team_editor, nil)

  def handle_event("select_team", id, socket) do
    team = Enum.find(socket.assigns.teams, fn t -> t.id == id end)
    socket = assign(socket, :team_editor, TeamEditor.construct(team))
    {:noreply, socket}
  end

  def handle_event("toggle_team_field", "activated", socket) do
    socket =
      update(socket, :team_editor, fn team_editor ->
        TeamEditor.toggle_activated(team_editor)
      end)

    {:noreply, socket}
  end

  def handle_event("update_team_name", %{"team" => team_params} = _params, socket) do
    socket =
      case TeamEditor.update_team_name(socket.assigns.team_editor, team_params) do
        {:ok, struct} -> refresh_state(socket, struct)
        {:error, changeset} -> refresh_state(socket, changeset)
      end

    {:noreply, socket}
  end

  def handle_event("toggle_group_expanded", uuid, socket) do
    socket =
      update(socket, :team_editor, fn team_editor ->
        TreeEditor.toggle_group_expanded(team_editor, uuid)
      end)

    {:noreply, socket}
  end

  def handle_event("edit_node", uuid, socket) do
    socket =
      update(socket, :team_editor, fn team_editor ->
        TreeEditor.edit_node(team_editor, uuid)
      end)

    {:noreply, socket}
  end

  def handle_event("update_node_name", %{"uuid" => uuid, "node" => node_params}, socket) do
    socket =
      case TreeEditor.update_node_name(socket.assigns.team_editor, uuid, node_params) do
        {:ok, editor} -> refresh_state(socket, editor)
        :error -> socket
      end

    {:noreply, socket}
  end

  defp refresh_state(socket, %TeamEditor{} = editor) do
    socket
    |> assign(:teams, Core.list_teams())
    |> assign(:team_editor, editor)
  end

  defp refresh_state(socket, %Core.Team{} = team) do
    socket
    |> assign(:teams, Core.list_teams())
    |> assign(:team_editor, TeamEditor.construct(team))
  end

  defp refresh_state(socket, %Ecto.Changeset{} = changeset) do
    update(socket, :team_editor, fn team_editor ->
      %{team_editor | changeset: changeset}
    end)
  end
end
