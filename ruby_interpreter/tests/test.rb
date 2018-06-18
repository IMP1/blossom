require 'date'

class Test

    class TestRun

        attr_reader :start_time
        attr_reader :result

        def initialize(block)
            @block = block
            @start_time = nil
            @result = nil
        end
        def started?
            return !@start_time.nil?
        end
        def finished?
            return !@result.nil?
        end
        def run(*args)
            @start_time = DateTime.now
            error = nil
            begin
                result_value = @block.call(*args)
                success = true
            rescue StandardError => e
                result_value = e
                success = false
                p e
                puts e.backtrace
            end
            end_time = DateTime.now
            @result = TestResult.new(result_value, @start_time, end_time, success)
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
        t = Thread.new {
            test_run.run
        }
        t.abort_on_exception = true
        t.join if blocking
        return test_run
    end

end

def assert(expression, message="")
    # TODO: have this raise an exception?
    if !expression
        puts "Assersion Failed: #{message}"
    end
end