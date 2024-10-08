defmodule BackendWeb.SubjectJSON do
  alias Backend.Subjects.Subject

  @doc """
  Renders a list of subjects.
  """
  def index(%{data: {:ok, %{list: list, pagination: pagination}}}) do
    %{list: for(subject <- list, do: data_short(subject)), pagination: pagination}
  end

  def index(%{data: {:error, _paylaod}}) do
    %{error: "Wrong params"}
  end

  @doc """
  Renders a single subject.
  """
  def show(%{subject: subject}), do: data(subject)

  defp data_short(%Subject{} = subject) do
    %{
      id: subject.id,
      title: subject.title,
      short_title: subject.short_title,
      inserted_at: subject.inserted_at,
      updated_at: subject.updated_at
    }
  end

  defp data(%Subject{} = subject) do
    %{
      id: subject.id,
      title: subject.title,
      short_title: subject.short_title,
      description: subject.description,
      prerequisites: subject.prerequisites,
      objectives: subject.objectives,
      required_texts: subject.required_texts,
      teachers:
        for(
          teacher <- subject.teachers,
          do: %{id: teacher.id, first_name: teacher.first_name, last_name: teacher.last_name}
        ),
      inserted_at: subject.inserted_at,
      updated_at: subject.updated_at
    }
  end
end
