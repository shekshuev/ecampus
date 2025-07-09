defmodule Ecampus.Groups do
  @moduledoc """
  The Groups context.

  Provides functions for listing, retrieving, creating, updating,
  and deleting academic groups.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Groups.Group

  @doc """
  Returns a paginated, filtered, and sorted list of groups using Flop.

  Accepts Flop parameters (e.g., filters, order, pagination) and returns
  a result with metadata.

  ## Examples

      iex> list_groups(%{"order_by" => "title", "limit" => 10})
      {[%Group{}, ...], %Flop.Meta{}}
  """
  @spec list_groups(map()) ::
          {[Group.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_groups(params) do
    Flop.validate_and_run!(Group, params, for: Group, replace_invalid_params: true)
  end

  @doc """
  Gets a single group by ID, preloading its associated speciality.

  Raises `Ecto.NoResultsError` if the group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_group!(integer()) :: Group.t()
  def get_group!(id), do: Repo.get!(Group, id) |> Repo.preload(:speciality)

  @doc """
  Creates a new group with the given attributes.

  Returns the inserted group with preloaded speciality on success.

  ## Examples

      iex> create_group(%{title: "A-101", ...})
      {:ok, %Group{}}

      iex> create_group(%{title: nil})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_group(map()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def create_group(attrs \\ %{}) do
    changeset =
      %Group{}
      |> Group.changeset(attrs)

    with {:ok, group} <- Repo.insert(changeset) do
      {:ok, Repo.preload(group, [:speciality])}
    end
  end

  @doc """
  Updates an existing group with new attributes.

  Returns the updated group with preloaded speciality on success.

  ## Examples

      iex> update_group(group, %{title: "B-202"})
      {:ok, %Group{}}

      iex> update_group(group, %{title: nil})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_group(Group.t(), map()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def update_group(%Group{} = group, attrs) do
    changeset =
      group
      |> Group.changeset(attrs)

    with {:ok, group} <- Repo.update(changeset) do
      {:ok, Repo.preload(group, [:speciality])}
    end
  end

  @doc """
  Deletes the given group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_group(Group.t()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  Useful for form rendering.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}
  """
  @spec change_group(Group.t(), map()) :: Ecto.Changeset.t()
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end
end
