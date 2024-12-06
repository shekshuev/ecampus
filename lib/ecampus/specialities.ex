defmodule Ecampus.Specialities do
  @moduledoc """
  The Specialities context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Specialities.Speciality

  @doc """
  Returns the list of specialities.

  ## Examples

      iex> list_specialities()
      [%Speciality{}, ...]

  """
  def list_specialities do
    Repo.all(Speciality)
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
  def get_speciality!(id), do: Repo.get!(Speciality, id)

  @doc """
  Creates a speciality.

  ## Examples

      iex> create_speciality(%{field: value})
      {:ok, %Speciality{}}

      iex> create_speciality(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
  def delete_speciality(%Speciality{} = speciality) do
    Repo.delete(speciality)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking speciality changes.

  ## Examples

      iex> change_speciality(speciality)
      %Ecto.Changeset{data: %Speciality{}}

  """
  def change_speciality(%Speciality{} = speciality, attrs \\ %{}) do
    Speciality.changeset(speciality, attrs)
  end
end
