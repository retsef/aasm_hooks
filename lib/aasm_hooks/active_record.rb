module AasmHooks
  module ActiveRecord
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      # Define hooks for all events and states
      #  aasm_define_event_hook(*aasm.events.collect(&:name))
      #
      #  before_close :do_before_close
      #  after_close :do_after_close
      #  guard_closed_to_opened :do_guard_closed_from_opened
      #  after_closed_to_opened :after_closed_from_opened
      #
      def has_aasm_hooks event_names=self.aasm.events.collect(&:name)
        event_names.each do |event_name|
          define_singleton_method("before_#{event_name}") do |*methods, &block|
            aasm_add_event_hook(event_name.to_s.to_sym, :before, *methods, &block)
          end

          define_singleton_method("after_#{event_name}") do |*methods, &block|
            aasm_add_event_hook(event_name.to_s.to_sym, :after, *methods, &block)
          end

          event = self.aasm.events.detect { |event| event.name == event_name }
          next unless event
          event.transitions.each do |transition|
            aasm_define_transition_hook(event_name, transition.from, transition.to)
          end
        end
      end

      private

      def aasm_define_transition_hook(event_name, from_state, to_state)
        define_singleton_method("guard_#{from_state}_to_#{to_state}") do |*methods, &block|
          aasm_add_transition_hook(event_name.to_s.to_sym, from_state, to_state, :guard, *methods, &block)
        end

        define_singleton_method("after_#{from_state}_to_#{to_state}") do |*methods, &block|
          aasm_add_transition_hook(event_name.to_s.to_sym, from_state, to_state, :after, *methods, &block)
        end
      end

      # Adds a :before or :after callback to an event
      #  aasm_add_event_hook(:start, :before, :my_method)
      def aasm_add_event_hook(event_name, action, *methods, &block)
        raise(ArgumentError, 'Cannot supply both a method name and a block') if methods.size.positive? && block
        raise(ArgumentError, 'Must supply either a method name or a block') unless methods.size.positive? || block

        # TODO: Somehow get AASM to support options such as :if and :unless to be consistent with other callbacks
        # For example:
        #    before_start :my_hook, unless: :encrypted?
        #    before_start :my_hook, if: :encrypted?
        event = self.aasm.events.detect { |event| event.name == event_name }
        raise(ArgumentError, "Unknown event: #{event_name}") unless event

        values = Array(event.options[action])
        code = block if block
        code ||= begin
                   # Validate methods are any of Symbol String Proc
                   methods.each do |method|
                     raise(ArgumentError, "#{action}_#{event_name} currently does not support any options. Only Symbol and String method names can be supplied.") unless method.is_a?(Symbol) || method.is_a?(String)
                   end
                   methods
                 end
        action == :before ? values.push(code) : values.unshift(code)
        event.options[action] = values.flatten.uniq
      end

      # Adds a :before or :after callback to a state transition
      #  aasm_add_transition_hook(:start, :idle, :running, :before, :my_method)
      def aasm_add_transition_hook(event_name, from_state, to_state, action, *methods, &block)
        raise(ArgumentError, 'Cannot supply both a method name and a block') if methods.size.positive? && block
        raise(ArgumentError, 'Must supply either a method name or a block') unless methods.size.positive? || block

        # TODO: Somehow get AASM to support options such as :if and :unless to be consistent with other callbacks
        # For example:
        #    before_end_from_start :my_hook, unless: :encrypted?
        #    before_end_from_start :my_hook, if: :encrypted?
        event = self.aasm.events.detect { |event| event.name == event_name }
        raise(ArgumentError, "Unknown event: #{event_name}") unless event

        transition = event.transitions.detect { |transition| transition.from == from_state && transition.to == to_state }
        raise(ArgumentError, "Unknown transition: #{event_name} from: #{from_state} to: #{to_state}") unless transition

        values = Array(event.options[action])
        code = block if block
        code ||= begin
                   # Validate methods are any of Symbol String Proc
                   methods.each do |method|
                     raise(ArgumentError, "#{action}_#{event_name} currently does not support any options. Only Symbol and String method names can be supplied.") unless method.is_a?(Symbol) || method.is_a?(String)
                   end
                   methods
                 end
        values.push(code)

        transition.options[action] = values.flatten.uniq

        # Inject in instance variables (only transition needs to be injected)
        case action
        when :guard
          transition.instance_variable_set(:@guards, values.flatten.uniq)
        when :after
          transition.instance_variable_set(:@after, values.flatten.uniq.first)
        end
      end
    end
  end
end
