# Return to Support

This guide covers `Publish::ReturnToSupport`, the concern that lets a Support admin start a flow in Publish and come back to the Support console when the flow ends.

## Why it exists

Some Support console features duplicated a Publish flow. For example, Support had its own screens to add schools and to remove accredited partnerships. Research with the support team found the duplicates confusing, so product asked for them to be removed. Support now links into the Publish flow instead.

An admin who starts in Support expects to end in Support. Without help, a Publish flow ends on a Publish page, and the admin loses their place in the Support list (page, sort order). `ReturnToSupport` fixes this. It:

- marks the journey as started from Support (`return_to=support`)
- carries the Support list state through every step of the Publish flow (`support_return[...]`)
- sends the admin back to the Support page, with that state, when the flow ends or is cancelled
- leaves the flow unchanged for provider users, who never see `return_to`

Flows that use it today:

| Support page | Publish flow | Return paths module |
| --- | --- | --- |
| Provider users | Add user | `ReturnPaths::Users` |
| Provider schools | Add school, add multiple schools, remove school | `ReturnPaths::Schools` |
| Provider accredited providers | Add accredited provider, remove accredited provider | `ReturnPaths::AccreditedPartnerships` |

## How it works

```
Support list page                    Publish flow                          Support list page
(page=3, sort=name)                                                        (page=3, sort=name)
       |                                                                          ^
       |  ?return_to=support&support_return[page]=3&support_return[sort]=name    |
       +--------> step 1 --> step 2 --> ... --> finish ---- redirect_to return_path
                  (every link, form and redirect passes **support_return_params)
```

The parts:

| Part | Where | What it does |
| --- | --- | --- |
| `publish_return_to_support_params(**state)` | `app/helpers/support/publish_return_helper.rb` | Used on **Support** pages. Builds `{ return_to: "support", support_return: state }` for the link into Publish. |
| `Publish::ReturnToSupport` | `app/controllers/concerns/publish/return_to_support.rb` | Used in **Publish** controllers. Reads the params and gives you the methods below. |
| `returning_to_support?` | concern, also a view helper | True when `return_to=support` and the current user is an admin. |
| `support_return_params` | concern, also a view helper | The params to pass on to the next step. Empty when `returning_to_support?` is false. |
| `support_flow_params` | concern | The flat values under `support_return`, as a symbol-keyed hash. |
| `return_path` | concern, also a view helper | `support_return_path(support_flow_params)` when returning to Support, otherwise `publish_return_path`. |
| `ReturnPaths::*` modules | `app/controllers/concerns/publish/return_paths/` | One per flow. Each defines `support_return_path(state)` and `publish_return_path`. |

The concern does not know about any model or route. Each flow supplies its own paths through a `ReturnPaths` module.

## Setting up a new flow

The example below sends a Support "widgets" tab into a Publish "add widget" flow. Replace the names with your own.

### 1. Write the return paths module

Create `app/controllers/concerns/publish/return_paths/widgets.rb`. It must define both methods.

```ruby
# frozen_string_literal: true

module Publish
  module ReturnPaths
    module Widgets
    private

      # Where an admin goes when the flow ends. `state` is the hash the
      # Support page put under support_return. Slice only the keys the
      # Support page understands.
      def support_return_path(state)
        support_recruitment_cycle_provider_widgets_path(
          provider.recruitment_cycle_year,
          provider,
          **state.slice(:page),
        )
      end

      # Where a provider user goes when the flow ends.
      def publish_return_path
        publish_provider_recruitment_cycle_widgets_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
        )
      end
    end
  end
end
```

`provider` comes from the including controller. If your flow has more than one controller (search, check, and so on), every one of them uses the same module.

### 2. Include the concern and the module in every Publish controller in the flow

```ruby
module Publish
  module Providers
    class WidgetsController < ApplicationController
      include ReturnToSupport
      include ReturnPaths::Widgets
      # ...
    end
  end
end
```

Do both. If you include only `ReturnToSupport`, `return_path` raises `NoMethodError` for provider users, because `publish_return_path` is missing. Admin tests that pass `return_to=support` do not hit this.

### 3. Link from the Support page

In the Support view, build the link with `publish_return_to_support_params`. Pass any list state the admin should get back.

```erb
<%= govuk_button_link_to(
  "Add widget",
  new_publish_provider_recruitment_cycle_widget_path(
    @provider.provider_code,
    @provider.recruitment_cycle_year,
    **publish_return_to_support_params(page: params[:page].presence),
  ),
) %>
```

Blank values are dropped, so `params[:page].presence` is safe when there is no page.

### 4. Pass the params through every step

Every URL the admin can follow inside the flow must include `**support_return_params`. This means:

- links to the next step, back links and change links
- form `url:` values (the params go in the query string, so `form_with` keeps them on submit)
- `redirect_to` between steps, including redirects for errors and guard conditions

```ruby
redirect_to check_publish_provider_recruitment_cycle_widgets_path(
  provider.provider_code,
  provider.recruitment_cycle_year,
  widget_id: @widget.id,
  **support_return_params,
)
```

```erb
<%= form_with(url: publish_provider_recruitment_cycle_widgets_path(**support_return_params), local: true) do |f| %>
```

If one URL leaves them out, the admin continues in the plain Publish flow from that step on, and ends on the Publish page.

### 5. End the flow with `return_path`

When the flow succeeds, redirect to `return_path`. Use `return_path` for Cancel links, and for Back links that leave the flow.

```ruby
def create
  if @widget.save
    set_added_flash
    redirect_to return_path
  else
    render :new, status: :unprocessable_content
  end
end
```

```erb
<%= govuk_link_to("Cancel", return_path) %>
```

### 6. Set the flash for each side

The concern does not set a flash. The flash you set before `redirect_to return_path` shows on whichever page the admin or user lands on. If the Support page needs a different message from the Publish page, branch on `returning_to_support?`. The accredited partnerships flow does this: Support shows the provider name in a `success_with_body` banner, and Publish shows a plain `success` message.

```ruby
def set_added_flash
  if returning_to_support?
    flash[:success_with_body] = {
      "title" => t(".added"),
      "body" => ERB::Util.html_escape(@widget.name),
    }
  else
    flash[:success] = t(".added")
  end
end
```

Escape the body. The flash banner renders `success_with_body` bodies with `html_safe`.

### 7. Remove the duplicate Support code

Delete the Support routes, actions, views, locale keys and components that the Publish flow replaces. The Support controller keeps only the list. It does not include `ReturnToSupport`.

### 8. Test it

- **System spec** in `spec/system/support/...`: start on the Support page, go through the Publish flow, check that you end on the Support page with the success banner and the list state you started with.
- **Publish system spec**: check that the plain Publish flow still ends on the Publish page. This is the case that breaks when `publish_return_path` is missing.
- **Request specs** only for cases you cannot do in a browser, such as a second submit of a form.

The concern itself is covered by `spec/controllers/concerns/publish/return_to_support_spec.rb`.

## Limitations

- **`support_return_params` is always empty on a Support page.** It reads `return_to` from the current request, and Support pages never get one. On Support pages, use `publish_return_to_support_params`. Do not include `ReturnToSupport` in a Support controller to make the method available.
- **A missing `publish_return_path` only breaks provider users.** `return_path` calls it only when `returning_to_support?` is false. Specs that always pass `return_to=support` pass, while the plain Publish flow raises `NoMethodError`.
- **One URL without `**support_return_params` breaks the return.** The concern cannot detect a dropped param. The flow continues as plain Publish and ends on the Publish page.
- **Only admins return to Support.** `returning_to_support?` checks `current_user.admin?`. A provider user who follows a link with `return_to=support` gets the plain Publish flow.
- **Only flat values pass through.** `support_flow_params` drops hashes and arrays under `support_return`. You cannot carry a filter set such as `support_return[filters][]`.
- **`support_return_path` decides which state is used.** The concern passes every flat key on. Slice the keys your Support page understands, so a changed query string cannot add unexpected params to the Support URL.
- **`success_with_body` bodies are not escaped by the banner.** Escape user or provider data with `ERB::Util.html_escape` before you put it in the flash.
