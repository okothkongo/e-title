defmodule ETitleWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as tables, forms, and
  inputs. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The foundation for styling is Tailwind CSS, a utility-first CSS framework,
  augmented with daisyUI, a Tailwind CSS plugin that provides UI components
  and themes. Here are useful references:

    * [daisyUI](https://daisyui.com/docs/intro/) - a good place to get
      started and see the available components.

    * [Tailwind CSS](https://tailwindcss.com) - the foundational framework
      we build on. You will use it for layout, sizing, flexbox, grid, and
      spacing.

    * [Heroicons](https://heroicons.com) - see `icon/1` for usage.

    * [Phoenix.Component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html) -
      the component system used by Phoenix. Some components, such as `<.link>`
      and `<.form>`, are defined there.

  """
  use Phoenix.Component
  use Gettext, backend: ETitleWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 right-4 z-50 max-w-sm w-full"
      {@rest}
    >
      <div class={[
        "bg-white rounded-lg shadow-xl border-l-4 p-4 transform transition-all duration-300 ease-out",
        @kind == :info && "border-blue-500 bg-blue-50",
        @kind == :error && "border-red-500 bg-red-50"
      ]}>
        <div class="flex items-start space-x-3">
          <.icon
            :if={@kind == :info}
            name="hero-information-circle"
            class="size-5 shrink-0 text-blue-500 mt-0.5"
          />
          <.icon
            :if={@kind == :error}
            name="hero-exclamation-circle"
            class="size-5 shrink-0 text-red-500 mt-0.5"
          />
          <div class="flex-1 min-w-0">
            <p :if={@title} class="font-semibold text-gray-900 mb-1">{@title}</p>
            <p class={[
              "text-sm leading-relaxed",
              @kind == :info && "text-blue-800",
              @kind == :error && "text-red-800"
            ]}>
              {msg}
            </p>
          </div>
          <button
            type="button"
            class="group self-start cursor-pointer p-1 rounded-full hover:bg-gray-100 transition-colors duration-150"
            aria-label={gettext("close")}
          >
            <.icon name="hero-x-mark" class="size-4 text-gray-400 group-hover:text-gray-600" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a e with navigation support.

  ## Variants
  - `primary`: Green gradient button with shadow and hover effects
  - `secondary`: White button with green border and hover effects
  - `danger`: Red gradient button for destructive actions
  - `outline`: Transparent button with gray border and green hover
  - `ghost`: Minimal button with subtle hover effects

  ## Sizes
  - `sm`: Small button (px-4 py-2 text-sm)
  - `md`: Medium button (px-6 py-3 text-base) - default
  - `lg`: Large button (px-8 py-4 text-lg)

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary" size="lg">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
      <.button variant="danger" size="sm">Delete</.button>
      <.button variant="outline">Cancel</.button>
      <.button variant="ghost">Skip</.button>
      <.button loading={true} variant="primary">Processing...</.button>
      <.button disabled={true} variant="primary">Disabled</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  attr :class, :string
  attr :variant, :string, values: ~w(primary secondary danger outline ghost), default: "primary"
  attr :size, :string, values: ~w(sm md lg), default: "md"
  attr :loading, :boolean, default: false
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    base_styles =
      "display: inline-block; font-weight: 600; cursor: pointer; user-select: none; " <>
        "border: none; outline: none; transition: all 0.3s ease;"

    variant_styles = button_variant(assigns[:variant])
    size_styles = button_size(assigns[:size])

    assigns =
      assign_new(assigns, :style, fn ->
        "#{base_styles} #{variant_styles} #{size_styles}"
      end)

    render_button(assigns, rest)
  end

  defp button_variant("primary"),
    do:
      "background-color: #059669; color: white; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);"

  defp button_variant("secondary"),
    do:
      "background-color: white; border: 2px solid #059669; color: #059669; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);"

  defp button_variant("danger"),
    do:
      "background-color: #dc2626; color: white; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);"

  defp button_variant("outline"),
    do:
      "background-color: transparent; border: 2px solid #d1d5db; color: #374151; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px 0 rgba(0,0,0,0.06);"

  defp button_variant("ghost"),
    do: "background-color: transparent; color: #4b5563; border: none; box-shadow: none;"

  defp button_variant(_),
    do: button_variant("primary")

  defp button_size("sm"),
    do: "padding: 0.5rem 1rem; font-size: 0.875rem; border-radius: 0.375rem;"

  defp button_size("lg"), do: "padding: 1rem 2rem; font-size: 1.125rem; border-radius: 0.75rem;"
  defp button_size(_), do: "padding: 0.75rem 1.5rem; font-size: 1rem; border-radius: 0.5rem;"

  defp render_button(assigns, rest) do
    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link style={@style} {@rest}>
        {render_button_content(@loading, @inner_block)}
      </.link>
      """
    else
      ~H"""
      <button style={@style} {@rest}>
        {render_button_content(@loading, @inner_block)}
      </button>
      """
    end
  end

  defp render_button_content(loading, inner_block) do
    assigns = %{loading: loading, inner_block: inner_block}

    ~H"""
    <div class="flex items-center justify-center space-x-2">
      <div
        :if={@loading}
        class="animate-spin rounded-full h-4 w-4 border-2 border-current border-t-transparent"
      >
      </div>
      <span>{render_slot(@inner_block)}</span>
    </div>
    """
  end

  @doc """
  Renders an icon button - a button with just an icon.

  ## Examples

      <.icon_button icon="hero-heart" variant="ghost" />
      <.icon_button icon="hero-trash" variant="danger" size="sm" />
  """
  attr :icon, :string, required: true
  attr :variant, :string, values: ~w(primary secondary danger outline ghost), default: "ghost"
  attr :size, :string, values: ~w(sm md lg), default: "md"
  attr :class, :string
  attr :rest, :global

  def icon_button(assigns) do
    size_classes = %{
      "sm" => "p-2",
      "md" => "p-3",
      "lg" => "p-4"
    }

    icon_sizes = %{
      "sm" => "size-4",
      "md" => "size-5",
      "lg" => "size-6"
    }

    base_classes =
      "rounded-lg font-semibold transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:cursor-not-allowed"

    variant_classes = %{
      "primary" =>
        "bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95",
      "secondary" =>
        "bg-white border-2 border-green-600 text-green-600 hover:bg-green-600 hover:text-white shadow-md hover:shadow-lg transform hover:scale-105 active:scale-95",
      "danger" =>
        "bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95",
      "outline" =>
        "bg-transparent border-2 border-gray-300 text-gray-700 hover:border-green-500 hover:text-green-600 shadow-sm hover:shadow-md transform hover:scale-105 active:scale-95",
      "ghost" =>
        "bg-transparent text-gray-600 hover:text-green-600 hover:bg-green-50 transform hover:scale-105 active:scale-95"
    }

    assigns =
      assign_new(assigns, :class, fn ->
        size_class = Map.fetch!(size_classes, assigns[:size])
        variant_class = Map.fetch!(variant_classes, assigns[:variant])
        "#{base_classes} #{size_class} #{variant_class}"
      end)

    assigns = assign(assigns, :icon_class, Map.fetch!(icon_sizes, assigns[:size]))

    ~H"""
    <button class={@class} {@rest}>
      <.icon name={@icon} class={@icon_class} />
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :string, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :string, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="fieldset mb-6">
      <label class="flex items-center space-x-3 cursor-pointer group">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <div class="relative">
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            class={
              @class ||
                "w-5 h-5 text-green-600 bg-white border-2 border-gray-300 rounded focus:ring-2 focus:ring-green-500 focus:ring-offset-2 focus:border-green-500 transition-all duration-200 hover:border-green-400"
            }
            {@rest}
          />
          <div class="absolute inset-0 w-5 h-5 bg-green-600 rounded opacity-0 transition-opacity duration-200 pointer-events-none {if @checked, do: 'opacity-100', else: ''}">
            <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
        </div>
        <span class="text-sm font-medium text-gray-700 group-hover:text-green-600 transition-colors duration-200">
          {@label}
        </span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="fieldset mb-6">
      <label>
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-2">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={[
            @class ||
              "w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200 bg-white shadow-sm hover:shadow-md focus:outline-none",
            @errors != [] &&
              (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="fieldset mb-6">
      <label>
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-2">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class ||
              "w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200 bg-white shadow-sm hover:shadow-md resize-none focus:outline-none",
            @errors != [] &&
              (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div class="fieldset mb-6">
      <label>
        <span :if={@label} class="block text-sm font-medium text-gray-700 mb-2">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class ||
              "w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200 bg-white shadow-sm hover:shadow-md focus:outline-none",
            @errors != [] &&
              (@error_class || "border-red-500 focus:ring-red-500 focus:border-red-500")
          ]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # Helper used by inputs to generate form errors
  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-2 items-center text-sm text-red-600 bg-red-50 px-3 py-2 rounded-lg border border-red-200">
      <.icon name="hero-exclamation-circle" class="size-4 text-red-500" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[
      @actions != [] && "flex items-center justify-between gap-6",
      "pb-6 mb-8 border-b border-gray-200"
    ]}>
      <div>
        <h1 class="text-2xl font-bold text-gray-900 leading-8 mb-2">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-base text-gray-600 leading-relaxed">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
    attr :class, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-hidden rounded-xl shadow-lg border border-gray-200">
      <table class="w-full bg-white">
        <thead class="bg-gradient-to-r from-green-600 to-green-700 text-white">
          <tr>
            <th :for={col <- @col} class="px-6 py-4 text-left text-sm font-semibold tracking-wide">
              {col[:label]}
            </th>
            <th :if={@action != []} class="px-6 py-4 text-left text-sm font-semibold tracking-wide">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody id={@id} phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}>
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors duration-150"
          >
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={[@row_click && "hover:cursor-pointer", "px-6 py-4 text-sm text-gray-700"]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="px-6 py-4 text-sm text-gray-700">
              <div class="flex gap-3">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <ul class="space-y-4">
      <li
        :for={item <- @item}
        class="bg-white rounded-lg border border-gray-200 shadow-sm p-6 hover:shadow-md transition-shadow duration-200"
      >
        <div class="space-y-2">
          <div class="text-sm font-semibold text-green-600 uppercase tracking-wide">{item.title}</div>
          <div class="text-gray-700 leading-relaxed">{render_slot(item)}</div>
        </div>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class, "inline-block"]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(ETitleWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ETitleWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
