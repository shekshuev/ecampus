defmodule EcampusWeb.SectionUnderDevelopment do
  use EcampusWeb, :live_component

  use Gettext, backend: EcampusWeb.Gettext

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center gap-8 h-4/5">
      <span class="hero-cog w-16 h-16" />
      <.header>
        {gettext("Section is under development")}
      </.header>
    </div>
    """
  end
end
