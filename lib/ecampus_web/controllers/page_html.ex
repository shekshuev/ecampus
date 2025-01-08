defmodule EcampusWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use EcampusWeb, :html

  use Gettext, backend: EcampusWeb.Gettext

  embed_templates "page_html/*"
end
