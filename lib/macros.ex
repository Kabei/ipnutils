defmodule Ipnutils.Macros do
  defmacro deftypes(do: do_list, else: {else_index, else_name}) do
    for {index, name} <- do_list do
      quote do
        def type_index(unquote(name)), do: unquote(index)
        def type_name(unquote(index)), do: unquote(name)
      end
    end ++
      [
        quote do
          def type_index(_), do: unquote(else_index)
          def type_name(_), do: unquote(else_name)
        end
      ]
  end

  defmacro deftypes(do: do_list) do
    for {index, name} <- do_list do
      quote do
        def type_index(unquote(name)), do: unquote(index)
        def type_name(unquote(index)), do: unquote(name)
      end
    end
  end

  defmacro defstatus(do: do_list, else: {else_index, else_name}) do
    for {index, name} <- do_list do
      quote do
        def status_index(unquote(name)), do: unquote(index)
        def status_name(unquote(index)), do: unquote(name)
      end
    end ++
      [
        quote do
          def status_index(_), do: unquote(else_index)
          def status_name(_), do: unquote(else_name)
        end
      ]
  end

  defmacro defstatus(do: do_list) do
    for {index, name} <- do_list do
      quote do
        def status_index(unquote(name)), do: unquote(index)
        def status_name(unquote(index)), do: unquote(name)
      end
    end
  end

  defmacro deferrors(do: do_list, else: txt_else) do
    for {code, txt} <- do_list do
      quote do
        def msg(unquote(code)), do: unquote(txt)
      end
    end ++
      [
        quote do
          def msg(_), do: unquote(txt_else)
        end
      ]
  end
end
