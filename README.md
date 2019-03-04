# CanvasShim
Short description and motivation.

## Usage
This Rails engine now allows decorating classes/modules/etc in Canvas LMS without altering Canvas's files

It can also be used as a standard Rails engine with it's own routes/controllers/views/etc

**To decorate controllers, helpers, models, lib stuff from CanvasLMS**

- Create an **_almost same named_** file using format "{filename}_decorator.rb" under Shim's /app/decorators following the same CanvasLMS path
- Then use .class_eval to override/extend the class being decorated

**To decorate a view from CanvasLMS**

- Create the **_same named_** file under /app/views following the same CanvasLMS path

    This file will get picked up in the engine first before it's found in CanvasLMS.  This overrides the
entire file giving you maximum flexibility to make edits, while keeping the original in CanvasLMS
for review or later upgrades


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
