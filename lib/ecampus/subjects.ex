defmodule Ecampus.Subjects do
  @moduledoc """
  The Subjects context.

  Provides functions for listing, retrieving, creating, updating,
  and deleting academic subjects.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  alias Ecampus.Subjects.Subject

  @doc """
  Returns a paginated, filtered, and sorted list of subjects using Flop.

  Accepts Flop parameters (e.g., filters, order, pagination) and returns
  a result with metadata.

  ## Examples

      iex> list_subjects(%{"order_by" => "title", "limit" => 10})
      {[%Subject{}, ...], %Flop.Meta{}}

  """
  @spec list_subjects(map()) :: {[Subject.t()], Flop.Meta.t()} | {:error, Flop.Meta.t()}
  def list_subjects(params) do
    Flop.validate_and_run!(Subject, params, for: Subject, replace_invalid_params: true)
  end

  @doc """
  Gets a single subject by ID.

  Raises `Ecto.NoResultsError` if the subject does not exist.

  ## Examples

      iex> get_subject!(123)
      %Subject{}

  """
  @spec get_subject!(integer()) :: Subject.t()
  def get_subject!(id), do: Repo.get!(Subject, id)

  @doc """
  Creates a new subject with the given attributes.

  ## Examples

      iex> create_subject(%{title: "Math", ...})
      {:ok, %Subject{}}

      iex> create_subject(%{title: nil})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_subject(map()) :: {:ok, Subject.t()} | {:error, Ecto.Changeset.t()}
  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing subject with new attributes.

  ## Examples

      iex> update_subject(subject, %{title: "Updated"})
      {:ok, %Subject{}}

      iex> update_subject(subject, %{title: nil})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_subject(Subject.t(), map()) :: {:ok, Subject.t()} | {:error, Ecto.Changeset.t()}
  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the given subject.

  ## Examples

      iex> delete_subject(subject)
      {:ok, %Subject{}}

  """
  @spec delete_subject(Subject.t()) :: {:ok, Subject.t()} | {:error, Ecto.Changeset.t()}
  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subject changes.

  Useful for form rendering.

  ## Examples

      iex> change_subject(subject)
      %Ecto.Changeset{data: %Subject{}}

  """
  @spec change_subject(Subject.t(), map()) :: Ecto.Changeset.t()
  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end
end
