require 'date'

require_relative '../objects/graph'
require_relative '../objects/node'
require_relative '../objects/edge'
require_relative '../objects/rule'
require_relative '../objects/label'
require_relative '../objects/function'
require_relative '../objects/procedure'
require_relative '../objects/label_value_expression'
require_relative '../objects/condition_expression'
require_relative '../objects/addendum_statement'
require_relative '../objects/rule_application'

class Test

    class AssertionError < RuntimeError
    end

    class TestRun

        INVALID = TestRun.new

        attr_reader :start_time
        attr_reader :thread

        def initialize(block)
            @block = block
            @start_time = nil
            @result = nil
            @thread = nil
        end
        def started?
            return !@start_time.nil?
        end
        def finished?
            return !@result.nil?
        end
        def run(*args)
            @thread = Thread.new do
                @start_time = DateTime.now
                error = nil
                begin
                    result_value = @block.call(*args)
                    success = true
                rescue StandardError => e
                    result_value = e
                    success = false
                end
                end_time = DateTime.now
                @result = TestResult.new(result_value, @start_time, end_time, success)
            end
            @thread.abort_on_exception = true
        end
        def result
            if self == INVALID
                return nil
            end
            if !finished?
                @thread.join
            end
            return @result
        end
        def ensure(&block)
            failures = []

            alias uncaught_assert assert
            method_name = "assert"
            define_singleton_method(method_name) do |expr, message=""| 
                begin
                    uncaught_assert(expr, message)
                rescue AssertionError => e
                    location = e.backtrace_locations.find {|loc| loc.to_s.include?("<main>") }
                    line     = location.lineno - 1
                    filename = location.absolute_path
                    assertion = File.readlines(filename)[line][/#{method_name}\((.+)\)/, 1]
                    failures.push(assertion)
                end
            end
            instance_exec(result, &block)
            alias assert uncaught_assert

            success = result&.success
            if !failures.empty?
                success = false
                puts "Failed Assertions:"
            end
            failures.each { |msg| puts "  * " + msg }
            puts "\nTest " + (success ? "succeeded" : "failed") + "."
            $last_test_result = result
        end
    end

    class TestResult

        attr_reader :start_time
        attr_reader :end_time
        attr_reader :success
        attr_reader :error
        attr_reader :value

        def initialize(value, start_time, end_time, success)
            @start_time = start_time
            @end_time = end_time
            @success = success
            if success
                @value = value
            else
                @error = value
            end
        end
    end

    @precondition_failures = []

    def self.run(blocking=false, &block)
        test_run = TestRun.new(block)
        if !@precondition_failures.empty?
            puts "Failed Pre-Conditions:"
            @precondition_failures.reject! { |msg| puts "  * " + msg; true }
            return TestRun::INVALID
        end
        test_run.run
        test_run.thread.join if blocking
        @precondition_failures.clear
        return test_run
    end

    def self.require(&block)
        @precondition_failures = []

        singleton_class.send(:alias_method, :uncaught_assert, :assert)
        method_name = "assert"
        define_singleton_method(method_name) do |expr, message=""| 
            begin
                uncaught_assert(expr, message)
            rescue AssertionError => e
                location = e.backtrace_locations.find {|loc| loc.to_s.include?("<main>") }
                line     = location.lineno - 1
                filename = location.absolute_path
                assertion = File.readlines(filename)[line][/#{method_name}\((.+)\)/, 1]
                @precondition_failures.push(assertion)
            end
        end
        instance_eval(&block)
        singleton_class.send(:alias_method, :assert, :uncaught_assert)
    end

end

def assert(expression, message=nil)
    if !expression
        message ||= "Test Assertion Failed."
        raise Test::AssertionError.new(message)
    end
end