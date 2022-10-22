# AasmHooks

This gem was made to decompose the callbacks of the flow in the [aasm](https://github.com/aasm/aasm) gem.
With AASM you need to define those callbacks in the aasm definition, but with this gem you can define them outside the aasm dsl definition.
I want to declare a more readable code, like the `before_action` or `after_commit` hooks

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add aasm_hooks

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install aasm_hooks

## Usage

On any class that use AASM just call after aasm `has_aasm_hooks` and it defines the hooks in the class.

For every event will be created `before_event` and `after_event` hooks.
For every transition will be created `guard_current_state_to_next_state` and `after_current_state_to_next_state` hooks.

Here an example:

```ruby
class Dummy
  include AASM

  attr_accessor :locked
      
  aasm do
    state :opened, initial: true
    state :closed
    event :close do
      transitions from: :opened, to: :closed
    end
    event :open do
      transitions from: :closed, to: :opened
    end
  end

  has_aasm_hooks
  
  before_close :do_before_close
  after_close :do_after_close

  guard_closed_to_opened :do_guard_closed_to_opened
  after_closed_to_opened :do_after_closed_to_opened

  private

  def locked?
    !locked
  end

  def do_before_close; end
  def do_after_close; end

  def do_guard_closed_to_opened
    locked?
  end
  def do_after_closed_to_opened; end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/retsef/aasm_hooks. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/aasm_hooks/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
