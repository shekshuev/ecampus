defmodule EcampusWeb.MdRenderer do
  @moduledoc """
  This module contains functions to render custom markdown content
  """
  @stop_rendering_flag "<!-- Rendering stopped -->"

  def parse_markdown(lesson_topic) do
    html_content =
      lesson_topic.content
      |> replace_custom_tags()
      |> String.split(@stop_rendering_flag)
      |> List.first()
      |> Earmark.as_html!()
      |> Phoenix.HTML.raw()

    lesson_topic |> Map.put("html_content", html_content)
  end

  defp replace_custom_tags(content) do
    Regex.replace(~r/\[quiz (\d+)\]/, content, fn _, id ->
      button_html = """
      <button phx-click="reload" phx-value-id="#{id}" class="custom-button">Quiz #{id}</button>
      """

      # TODO test value, add db check here
      test = String.to_integer(id) > 0

      if test do
        "#{button_html}"
      else
        "#{button_html}\n#{@stop_rendering_flag}"
      end
    end)
  end
end
