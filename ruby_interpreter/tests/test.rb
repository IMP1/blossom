require 'date'

class Test

    class AssertionError < RuntimeError
    end

    class TestRun

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
            if @result.nil?
                @thread.join
            end
            return @result
        end
        def assert(&block)
            begin
                block.call(result)
                success = result.success
            rescue AssertionError => e
                puts e
                puts e.backtrace
                success = false
            end
            puts "Test " + (success ? "succeeded" : "failed") + "."
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

    def self.run(blocking=false, &block)
        test_run = TestRun.new(block)
        test_run.run
        test_run.thread.join if blocking
        return test_run
    end

end

def assert(expression, message="")
    if !expression
        raise AssertionError.new("Assersion Failed: #{message}")
    end
end