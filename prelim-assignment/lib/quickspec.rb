dir = File.dirname(File.expand_path(__FILE__))

require(File.join(dir, "base.rb"))

module QuickSpec
	@status = 0

	class << self
		attr_accessor :status
	end

	module Expectations
		class ExpectationNotMetError < Exception
		end

		class ExpectationTarget
			def initialize(observed)
				super()
				@observed = observed
				return
			end

			def to(matcher)
				matcher.to(@observed)
				return
			end

			def not_to(matcher)
				matcher.not_to(@observed)
				return
			end
		end
	end

	module Matchers
		module BuiltIn
			class YieldProbe
				def initialize
					super()
					@yielded_args = []
					return
				end

				attr_reader :yielded_args

				def call(args)
					if args.size == 1
						@yielded_args.push(args.first)
					else
						@yielded_args.push(args)
					end
					return
				end

				def to_proc
					return lambda { |*args| call(args) }
				end
			end

			class BaseMatcher
				def initialize(expected)
					super()
					@expected = expected
					return
				end
			end

			class BeA < BaseMatcher
				def to(observed)
					unless observed.is_a?(@expected)
						message = "expected #{observed.inspect} to be a #{@expected.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end

				def not_to(observed)
					if observed.is_a?(@expected)
						message = "expected #{observed.inspect} not to be a #{@expected.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end
			end

			class Eql < BaseMatcher
				def to(observed)
					unless observed.eql?(@expected)
						message = "expected #{observed.inspect} to eql #{@expected.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end

				def not_to(observed)
					if observed.eql?(@expected)
						message = "expected #{observed.inspect} not to eql #{@expected.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end
			end

			class RaiseError < BaseMatcher
				def to(observed)
					begin
						observed.call
					rescue @expected
						return
					end
					message = "expected to raise #{@expected.inspect}"
					raise Expectations::ExpectationNotMetError.new(message)
				end

				def not_to(observed)
					begin
						observed.call
					rescue @expected
						message = "expected not to raise #{@expected.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end
			end

			class YieldControl < BaseMatcher
				def to(observed)
					probe = YieldProbe.new
					observed.call(probe)
					if probe.yielded_args.empty?
						message = "expected to yield"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end

				def not_to(observed)
					probe = YieldProbe.new
					observed.call(probe)
					unless probe.yielded_args.empty?
						message = "expected not to yield but yielded #{probe.yielded_args.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end
			end

			class YieldSuccessiveArgs < BaseMatcher
				def to(observed)
					probe = YieldProbe.new
					observed.call(probe)
					unless probe.yielded_args.eql?(@expected)
						message = "expected to yield #{@expected.inspect} but yielded #{probe.yielded_args.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end

				def not_to(observed)
					probe = YieldProbe.new
					observed.call(probe)
					if probe.yielded_args.eql?(@expected)
						message = "expected not to yield #{@expected.inspect} but yielded #{probe.yielded_args.inspect}"
						raise Expectations::ExpectationNotMetError.new(message)
					end
					return
				end
			end
		end

		def expect(observed = nix, &block)
			if block_given?
				unless observed.nix?
					raise ArgumentError.new
				end
				return Expectations::ExpectationTarget.new(block)
			else
				if observed.nix?
					raise ArgumentError.new
				end
				return Expectations::ExpectationTarget.new(observed)
			end
		end

		def be_a(expected)
			return BuiltIn::BeA.new(expected)
		end

		def eql(expected)
			return BuiltIn::Eql.new(expected)
		end

		def raise_error(expected)
			return BuiltIn::RaiseError.new(expected)
		end

		def yield_control
			return BuiltIn::YieldControl.new(nil)
		end

		def yield_successive_args(*args)
			return BuiltIn::YieldSuccessiveArgs.new(args)
		end
	end

	module Core
		class << self
			def puts_exception_message(e)
				if e.is_a?(Expectations::ExpectationNotMetError)
					puts <<-END
    #{e.message}
					END
				else
					puts <<-END
    #{e.class}: #{e.message}
					END
				end
				return
			end

			def puts_exception_backtrace(e)
				first = true
				e.backtrace.each do |line|
					if line.start_with?("#{__FILE__}:")
						unless first
							break
						end
					else
						first = false
						puts <<-END
      #{line}
						END
					end
				end
				return
			end

			def puts_exception(e)
				puts_exception_message(e)
				puts_exception_backtrace(e)
				return
			end
		end

		class ExampleGroup
			include Matchers

			class << self
				def it(message, &block)
					print "  it #{message}... "
					begin
						new.instance_eval(&block)
					rescue Exception
						puts "fail"
						Core.puts_exception($!)
						QuickSpec.status = 1
						return
					end
					puts "ok"
					return
				end
			end
		end
	end

	class << self
		def describe(name, &block)
			puts
			puts <<-END
describe #{name}:
			END
			c = Class.new(Core::ExampleGroup)
			c.class_eval(&block)
			return
		end
	end
end

class << self
	def describe(name, &block)
		QuickSpec.describe(name, &block)
		return
	end
end
