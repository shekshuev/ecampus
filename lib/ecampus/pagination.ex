defmodule Ecampus.Pagination do
  @moduledoc """
  Pagination module to use in contexts
  """

  def with_pagination(
        {:ok,
         {list,
          %{total_pages: pages, total_count: count, flop: %{page: page, page_size: page_size}} =
            _meta}}
      ),
      do: {
        :ok,
        %{
          pagination: %{
            count: count,
            pages: pages,
            page_size: page_size,
            page: page
          },
          list: list
        }
      }

  def with_pagination({:error, %{errors: errors}}),
    do: {
      :error,
      %{
        pagination: nil,
        list: nil,
        errors: errors
      }
    }
end
