defmodule Ecampus.Specialities do
  @moduledoc """
  The Specialities context.

  Provides functions for listing, retrieving, creating, updating,
  and deleting academic specialities.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Specialities.Speciality

  @doc """
  Returns a paginated, filtered, and sorted list of specialities using Flop.

  Accepts Flop parameters (e.g., filters, order, pagination) and returns
  a result with metadata.

  ## Examples

      iex> list_specialities(%{"order_by" => "title", "limit" => 10})
      {[%Speciality{}, ...], %Flop.Meta{}}

  """
  @spec list_specialities(map()) ::
          {[Speciality.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_specialities(params) do
    Flop.validate_and_run!(Speciality, params, for: Speciality, replace_invalid_params: true)
  end

  @doc """
  Gets a single speciality.

  Raises `Ecto.NoResultsError` if the Speciality does not exist.

  ## Examples

      iex> get_speciality!(123)
      %Speciality{}

      iex> get_speciality!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_speciality!(integer()) :: Speciality.t()
  def get_speciality!(id), do: Repo.get!(Speciality, id)

  @doc """
  Creates a speciality.

  ## Examples

      iex> create_speciality(%{field: value})
      {:ok, %Speciality{}}

      iex> create_speciality(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_speciality(map()) :: {:ok, Speciality.t()} | {:error, Ecto.Changeset.t()}
  def create_speciality(attrs \\ %{}) do
    %Speciality{}
    |> Speciality.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a speciality.

  ## Examples

      iex> update_speciality(speciality, %{field: new_value})
      {:ok, %Speciality{}}

      iex> update_speciality(speciality, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_speciality(Speciality.t(), map()) ::
          {:ok, Speciality.t()} | {:error, Ecto.Changeset.t()}
  def update_speciality(%Speciality{} = speciality, attrs) do
    speciality
    |> Speciality.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a speciality.

  ## Examples

      iex> delete_speciality(speciality)
      {:ok, %Speciality{}}

      iex> delete_speciality(speciality)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_speciality(Speciality.t()) :: {:ok, Speciality.t()} | {:error, Ecto.Changeset.t()}
  def delete_speciality(%Speciality{} = speciality) do
    speciality
    |> Speciality.delete_changeset()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking speciality changes.

  ## Examples

      iex> change_speciality(speciality)
      %Ecto.Changeset{data: %Speciality{}}

  """
  @spec change_speciality(Speciality.t(), map()) :: Ecto.Changeset.t()
  def change_speciality(%Speciality{} = speciality, attrs \\ %{}) do
    Speciality.changeset(speciality, attrs)
  end
end
