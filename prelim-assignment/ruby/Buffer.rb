## <>
##   @bytes: Array<Integer>
class Buffer
	US_ASCII = 0x00 .. 0x7F
	ASCII_8BIT = 0x00 .. 0xFF

	class << self
		## Integer -> void
		def __assert_positive(n)
			unless n > 0
				raise ArgumentError.new("n must be positive")
			end
			return
		end

		## Integer -> void
		def __assert_nonnegative(n)
			if n < 0
				raise ArgumentError.new("n must be nonnegative")
			end
			return
		end

		## Integer -> void
		def __assert_range(b)
			unless ASCII_8BIT.member?(b)
				raise RangeError.new("invalid byte value: #{b}")
			end
			return
		end

		## Integer -> Buffer
		## Integer, Integer -> Buffer
		## Integer, &{Integer -> Integer} -> Buffer
		def new(n, b = nix)
			Buffer.__assert_nonnegative(n)
			if block_given?
				bytes = Array.new(n)
				n.times do |i|
					b = yield(i)
					Buffer.__assert_range(b)
					bytes[i] = b
				end
			elsif b.nix?
				bytes = Array.new(n, 0x00)
			else
				Buffer.__assert_range(b)
				bytes = Array.new(n, b)
			end
			return Buffer.__new__(bytes)
		end

		## *Integer -> Buffer
		def [](*bytes)
			n = bytes.size
			n.times do |i|
				b = bytes.fetch(i)
				Buffer.__assert_range(b)
			end
			return Buffer.__new__(bytes)
		end

		## *Buffer -> Buffer
		def join(*buffers)
			bytes = []
			buffers.each do |buffer|
				bytes.concat(buffer.__bytes)
			end
			return Buffer.__new__(bytes)
		end

		## String -> Buffer
		def unpack(s)
			bytes = s.unpack("C*")
			return Buffer.__new__(bytes)
		end

		## Integer -> Buffer
		## Integer, Integer -> Buffer
		def from_i(k, n = nix)
			if n.nix?
				n = 16
			else
				Buffer.__assert_nonnegative(n)
			end
			return __from_i(k, n)
		end

		#
		# Write about 5 lines of code for this method.
		#
		## Integer, Integer -> Buffer
		def __from_i(k, n)
			raise NotImplementedError
		end
	end

	## Array<Integer> -> void
	def initialize(bytes)
		super()
		@bytes = bytes
		return
	end

	## -> Array<Integer>
	def __bytes
		return @bytes
	end

	## Integer, Integer -> Buffer
	def __copy(i, j)
		bytes = @bytes.slice(i ... j).not_nil!
		return Buffer.__new__(bytes)
	end

	## ..Object? -> void
	def initialize_copy(o)
		@bytes = @bytes.dup
		return
	end

	## ..Object? -> boolean
	def eql?(o)
		if o.is_a?(Buffer)
			if size == o.size
				size.times do |i|
					unless @bytes[i].eql?(o.__bytes[i])
						return false
					end
				end
				return true
			end
		end
		return false
	end

	## -> Integer
	def hash
		h = 0x811C9DC5
		@bytes.each do |b|
			h = (h ^ b) * 0x01000193
		end
		return h & 0xFFFFFFFFFFFFFFFF
	end

	## -> String
	def inspect
		return "Buffer" + "[" + @bytes.map { |b| "0x%02X" % b }.join(", ") + "]"
	end

	## -> String
	def to_s
		return @bytes.map { |b| "%02X" % b }.join("-")
	end

	## -> self
	def freeze
		@bytes.freeze
		return self
	end

	## -> Integer
	def size
		return @bytes.size
	end

	## -> boolean
	def empty?
		return @bytes.empty?
	end

	#
	# Write about 4 lines of code for this method.
	#
	## -> Integer
	def to_i
		raise NotImplementedError
	end

	## -> Buffer
	def succ
		buffer = dup
		buffer.succ!
		return buffer
	end

	#
	# Write about 8 lines of code for this method.
	#
	## -> void
	def succ!
		raise NotImplementedError
	end

	## ..Object? -> boolean
	def ==(o)
		return eql?(o)
	end

	## Integer -> Integer
	def [](i)
		if i < 0 || i >= size
			raise IndexError.new("index #{i} out of bounds for size #{size}")
		end
		return @bytes.fetch(i)
	end

	## Integer, Integer -> void
	def []=(i, b)
		if i < 0 || i >= size
			raise IndexError.new("index #{i} out of bounds for size #{size}")
		end
		Buffer.__assert_range(b)
		@bytes[i] = b
		return
	end

	## Buffer -> Buffer
	def **(o)
		return Buffer.__new__(@bytes + o.__bytes)
	end

	## Integer -> Buffer
	## Buffer -> Buffer
	def ^(o)
		case o
		when Integer
			Buffer.__assert_range(o)
			return __xor_byte(o)
		when Buffer
			return __xor_buffer(o)
		else
			raise TypeError.new
		end
	end

	#
	# Write about 3 lines of code for this method.
	#
	## Integer -> Buffer
	def __xor_byte(o)
		raise NotImplementedError
	end

	#
	# Write about 4 lines of code for this method.
	#
	## Buffer -> Buffer
	def __xor_buffer(o)
		raise NotImplementedError
	end

	## -> String
	def pack
		return @bytes.pack("C*")
	end

	## Integer -> Integer
	def byte(i)
		if i < 0 || i >= size
			raise IndexError.new("index #{i} out of bounds for size #{size}")
		end
		return @bytes.fetch(i)
	end

	## -> Array<Integer>
	def bytes
		return @bytes.dup
	end

	## &{Integer -> void} -> void
	def each_byte
		@bytes.each do |b|
			yield b
		end
		return
	end

	## Integer -> Buffer
	## Integer, Integer -> Buffer
	def slice(i, n = nix)
		if n.nix?
			n = 16
		else
			Buffer.__assert_positive(n)
		end
		return __slice(i, n)
	end

	#
	# Write about 4 lines of code for this method.
	#
	## Integer, Integer -> Buffer
	def __slice(i, n)
		raise NotImplementedError
	end

	## -> Array<Buffer>
	## Integer -> Array<Buffer>
	def slices(n = nix)
		if n.nix?
			n = 16
		else
			Buffer.__assert_positive(n)
		end
		return __slices(n)
	end

	#
	# Write about 7 lines of code for this method.
	#
	## Integer -> Array<Buffer>
	def __slices(n)
		raise NotImplementedError
	end

	## &{Buffer -> void} -> void
	## Integer, &{Buffer -> void} -> void
	def each_slice(n = nix, &block)
		if n.nix?
			n = 16
		else
			Buffer.__assert_positive(n)
		end
		__each_slice(n, &block)
		return
	end

	#
	# Write about 5 lines of code for this method.
	#
	## Integer, &{Buffer -> void} -> void
	def __each_slice(n)
		raise NotImplementedError
	end
end
