# PipelineService
Pipeline service publishes lifecycle changes over a pipeline to federate our data and make it available widely to the organization

## Usage
PipelineService.publish(submission)

## Serializers
Active record objects are transformed via "serializers" into "nouns" that are published.  Currently there are two ways that the noun is built, throuh a generic ActiveRecord JSON serializer or a call to the Canvas API (depricated).

### Submission


**To decorate a view from CanvasLMS**

- Create the **_same named_** file under /app/views following the same CanvasLMS path

    This file will get picked up in the engine first before it's found in CanvasLMS.  This overrides the
entire file giving you maximum flexibility to make edits, while keeping the original in CanvasLMS
for review or later upgrades

**To include assets JS/CSS into Canvas LMS**

If you're decorating a page in CanvasLMS and need assets

- In your overriding view wrap your js/css includes in a :strongming_assets block, this block is yielded at the bottom of Canvas's application layout

```html
<% content_for :strongmind_assets do %>
  <%= stylesheet_link_tag    "canvas_shim/application", media: "all" %>
  <%= javascript_include_tag 'canvas_shim/application' %>
<% end %>
```
- If you're working in views that are a part of the shim engine, and you want shim to have a unique layout, everything works at a typical Rails app where Shim has it's own layout(s) for it's internal controllers

- **Note** that jQuery's ready event doesn't seem to fire with Canvas, you should be able to use window.on 'load' instead

```javascript
$(window).on("load", function(event) {
  // Some awesome code here
})
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'canvas_shim'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install canvas_shim
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
