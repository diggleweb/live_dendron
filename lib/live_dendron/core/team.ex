defmodule LiveDendron.Core.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "core_teams" do
    field(:name, :string)
    field(:organization_tree, :binary)
    field(:being_edited, :boolean, default: false, virtual: true)
    field(:changeset, :any, virtual: true)

    timestamps()
  end

  @required_fields [:name, :organization_tree]

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end