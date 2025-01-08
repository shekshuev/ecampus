defmodule Ecampus.Uploaders.SubjectCover do
  @moduledoc """
  The uploader module for subject cover
  """

  use Waffle.Definition

  @versions [:original]
  @allowed_extensions ~w(.jpg .jpeg .png)

  def storage_dir(_version, {_file, _scope}) do
    "uploads/subjects"
  end

  def validate(_version, {file, _scope}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(@allowed_extensions, file_extension)
  end
end
