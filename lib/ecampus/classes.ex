defmodule Ecampus.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false
  alias Ecampus.Repo

  import Ecampus.Pagination

  alias Ecampus.Classes.Class

  @doc """
  Returns the list of classes.

  ## Examples

      iex> list_classes()
      [%Class{}, ...]

  """
  def list_classes(params \\ %{}) do
    filters = []

    filters =
      params
      |> Enum.reduce(filters, fn
        {"begin_date", value}, acc ->
          [%{field: :begin_date, value: value} | acc]

        {"end_date", value}, acc ->
          [%{field: :end_date, value: value} | acc]

        {"classroom", value}, acc ->
          [%{field: :classroom, value: value} | acc]

        {"lesson_id", value}, acc ->
          [%{field: :lesson_id, value: value} | acc]

        {"group_id", value}, acc ->
          [%{field: :group_id, value: value} | acc]

        _, acc ->
          acc
      end)

    Class
    |> preload([:lesson, :group])
    |> Flop.validate_and_run(
      %{
        page: Map.get(params, "page", 1),
        page_size: Map.get(params, "page_size", 10),
        filters: filters,
        order_by: [:begin_date, :end_date],
        order_directions: [:asc, :asc]
      },
      for: Class
    )
    |> with_pagination()
  end

  @doc """
  Gets a single class.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

      iex> get_class!(123)
      %Class{}

      iex> get_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_class!(id), do: Repo.get!(Class, id) |> Repo.preload([:lesson, :group])

  @doc """
  Creates a class.

  ## Examples

      iex> create_class(%{field: value})
      {:ok, %Class{}}

      iex> create_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_class(attrs \\ %{}) do
    changeset =
      %Class{}
      |> Class.changeset(attrs)

    with {:ok, class} <- Repo.insert(changeset) do
      {:ok, Repo.preload(class, [:lesson, :group])}
    end
  end

  @doc """
  Updates a class.

  ## Examples

      iex> update_class(class, %{field: new_value})
      {:ok, %Class{}}

      iex> update_class(class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    changeset =
      class
      |> Class.changeset(attrs)

    with {:ok, class} <- Repo.update(changeset) do
      {:ok, Repo.preload(class, [:lesson, :group])}
    end
  end

  @doc """
  Deletes a class.

  ## Examples

      iex> delete_class(class)
      {:ok, %Class{}}

      iex> delete_class(class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

      iex> change_class(class)
      %Ecto.Changeset{data: %Class{}}

  """
  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end
end
