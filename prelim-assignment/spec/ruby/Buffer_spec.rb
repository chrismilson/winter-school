require "spec_helper"

describe "Buffer.[]" do
	it "should raise error for invalid byte value" do
		expect {
			Buffer[-1]
		}.to raise_error(RangeError)
	end

	it "should raise error for invalid byte value" do
		expect {
			Buffer[256]
		}.to raise_error(RangeError)
	end

	it "should return new buffer" do
		buffer = Buffer[0x00, 0xFF]
		expect(buffer).to be_a(Buffer)
	end
end

describe "Buffer.new" do
	it "should raise error for invalid size" do
		expect {
			Buffer.new(-1)
		}.to raise_error(ArgumentError)
	end

	it "should return new buffer with no bytes" do
		buffer = Buffer.new(0)
		expect(buffer).to eql(Buffer[])
	end

	it "should return new buffer with zero bytes" do
		buffer = Buffer.new(3)
		expect(buffer).to eql(Buffer[0x00, 0x00, 0x00])
	end

	it "should raise error for invalid byte value" do
		expect {
			Buffer.new(3, -1)
		}.to raise_error(RangeError)
	end

	it "should raise error for invalid byte value" do
		expect {
			Buffer.new(3, 256)
		}.to raise_error(RangeError)
	end

	it "should return new buffer with given byte" do
		buffer = Buffer.new(3, 0x20)
		expect(buffer).to eql(Buffer[0x20, 0x20, 0x20])
	end

	it "should raise error for invalid byte value" do
		expect {
			Buffer.new(3) { |i| -1 }
		}.to raise_error(RangeError)
	end

	it "should raise error for invalid byte value" do
		expect {
			Buffer.new(3) { |i| 256 }
		}.to raise_error(RangeError)
	end

	it "should return new buffer with bytes from given block" do
		buffer = Buffer.new(3) { |i| 0x30 + i }
		expect(buffer).to eql(Buffer[0x30, 0x31, 0x32])
	end
end

describe "Buffer.join" do
	it "should return new buffer with bytes from given buffers" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x62, 0x63]
		buffer = Buffer.join(buffer0, buffer1)
		expect(buffer).to eql(Buffer[0x61, 0x62, 0x63])
	end
end

describe "Buffer.from_i" do
	it "should raise error for value out of range" do
		expect {
			Buffer.from_i(-1)
		}.to raise_error(RangeError)
	end

	it "should return new buffer with big-endian representation of 0" do
		buffer = Buffer.from_i(0, 3)
		expect(buffer).to eql(Buffer[0x00, 0x00, 0x00])
	end

	it "should return new buffer with big-endian representation of 1" do
		buffer = Buffer.from_i(1, 3)
		expect(buffer).to eql(Buffer[0x00, 0x00, 0x01])
	end

	it "should return new buffer with big-endian representation of 16777215" do
		buffer = Buffer.from_i(16777215, 3)
		expect(buffer).to eql(Buffer[0xFF, 0xFF, 0xFF])
	end

	it "should raise error for value out of range" do
		expect {
			Buffer.from_i(16777216, 3)
		}.to raise_error(RangeError)
	end
end

describe "Buffer.unpack" do
	it "should return new buffer with bytes of given string" do
		buffer = Buffer.unpack("abc")
		expect(buffer).to eql(Buffer[0x61, 0x62, 0x63])
	end
end

describe "Buffer#dup" do
	it "should return new buffer with same bytes" do
		buffer0 = Buffer[0x61]
		buffer1 = buffer0.dup
		expect(buffer1).to eql(buffer0)
		buffer1[0] = 0x62
		expect(buffer0).to eql(Buffer[0x61])
	end
end

describe "Buffer#eql?" do
	it "should return true for buffers with same bytes" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x61]
		z = buffer0.eql?(buffer1)
		expect(z).to eql(true)
	end

	it "should return false for buffers with different bytes" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x62]
		z = buffer0.eql?(buffer1)
		expect(z).to eql(false)
	end
end

describe "Buffer#freeze" do
	it "should freeze buffer" do
		buffer = Buffer[0x61, 0x62, 0x63].freeze
		expect {
			buffer[1] = 0x20
		}.to raise_error(RuntimeError)
	end
end

describe "Buffer#size" do
	it "should return 0 for buffer of size 0" do
		buffer = Buffer[]
		n = buffer.size
		expect(n).to eql(0)
	end

	it "should return 3 for buffer of size 3" do
		buffer = Buffer[0x61, 0x62, 0x63]
		n = buffer.size
		expect(n).to eql(3)
	end
end

describe "Buffer#empty?" do
	it "should return true if buffer is empty" do
		buffer = Buffer[]
		z = buffer.empty?
		expect(z).to eql(true)
	end

	it "should return false if buffer is not empty" do
		buffer = Buffer[0x61, 0x62, 0x63]
		z = buffer.empty?
		expect(z).to eql(false)
	end
end

describe "Buffer#to_i" do
	it "should return 0 for buffer with big-endian representation of 0" do
		i = Buffer[0x00, 0x00, 0x00].to_i
		expect(i).to eql(0)
	end

	it "should return 1 for buffer with big-endian representation of 1" do
		i = Buffer[0x00, 0x00, 0x01].to_i
		expect(i).to eql(1)
	end

	it "should return 16777215 for buffer with big-endian representation of 16777215" do
		i = Buffer[0xFF, 0xFF, 0xFF].to_i
		expect(i).to eql(16777215)
	end
end

describe "Buffer#succ" do
	it "should return new buffer with successor of big-endian representation of 0" do
		buffer0 = Buffer[0x00, 0x00, 0x00]
		buffer1 = buffer0.succ
		expect(buffer1).to eql(Buffer[0x00, 0x00, 0x01])
	end

	it "should return new buffer with successor of big-endian representation of 255" do
		buffer0 = Buffer[0x00, 0x00, 0xFF]
		buffer1 = buffer0.succ
		expect(buffer1).to eql(Buffer[0x00, 0x01, 0x00])
	end

	it "should return new buffer with successor of big-endian representation of 65535" do
		buffer0 = Buffer[0x00, 0xFF, 0xFF]
		buffer1 = buffer0.succ
		expect(buffer1).to eql(Buffer[0x01, 0x00, 0x00])
	end
end

describe "Buffer#succ!" do
	it "should update buffer with successor of big-endian representation of 0" do
		buffer = Buffer[0x00, 0x00, 0x00]
		buffer.succ!
		expect(buffer).to eql(Buffer[0x00, 0x00, 0x01])
	end

	it "should update buffer with successor of big-endian representation of 255" do
		buffer = Buffer[0x00, 0x00, 0xFF]
		buffer.succ!
		expect(buffer).to eql(Buffer[0x00, 0x01, 0x00])
	end

	it "should update buffer with successor of big-endian representation of 65535" do
		buffer = Buffer[0x00, 0xFF, 0xFF]
		buffer.succ!
		expect(buffer).to eql(Buffer[0x01, 0x00, 0x00])
	end
end

describe "Buffer#==" do
	it "should return true for buffers with same bytes" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x61]
		z = buffer0 == buffer1
		expect(z).to eql(true)
	end

	it "should return false for buffers with different bytes" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x62]
		z = buffer0 == buffer1
		expect(z).to eql(false)
	end
end

describe "Buffer#[]" do
	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer[-1]
		}.to raise_error(IndexError)
	end

	it "should return byte value at index" do
		buffer = Buffer[0x61, 0x62, 0x63]
		b = buffer[1]
		expect(b).to eql(0x62)
	end

	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer[3]
		}.to raise_error(IndexError)
	end
end

describe "Buffer#[]=" do
	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer[-1] = 0x20
		}.to raise_error(IndexError)
	end

	it "should update byte value at index" do
		buffer = Buffer[0x61, 0x62, 0x63]
		buffer[1] = 0x20
		expect(buffer).to eql(Buffer[0x61, 0x20, 0x63])
	end

	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer[3] = 0x20
		}.to raise_error(IndexError)
	end
end

describe "Buffer#**" do
	it "should return new buffer with bytes of given buffers" do
		buffer0 = Buffer[0x61]
		buffer1 = Buffer[0x62, 0x63]
		buffer = buffer0 ** buffer1
		expect(buffer).to eql(Buffer[0x61, 0x62, 0x63])
	end
end

describe "Buffer#^" do
	it "should return new buffer with bytes XORed with key byte" do
		buffer0 = Buffer[0x61, 0x62, 0x63]
		buffer1 = buffer0 ^ 0x20
		expect(buffer1).to eql(Buffer[0x41, 0x42, 0x43])
	end

	it "should return new buffer with bytes XORed with repeating key bytes" do
		buffer0 = Buffer[0x61, 0x62, 0x63]
		buffer1 = Buffer[0x20, 0x40]
		buffer = buffer0 ^ buffer1
		expect(buffer).to eql(Buffer[0x41, 0x22, 0x43])
	end
end

describe "Buffer#pack" do
	it "should return string from bytes" do
		buffer = Buffer[0x61, 0x62, 0x63]
		s = buffer.pack
		expect(s).to eql("abc")
	end
end

describe "Buffer#byte" do
	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer.byte(-1)
		}.to raise_error(IndexError)
	end

	it "should return byte at index 0" do
		buffer = Buffer[0x61, 0x62, 0x63]
		b = buffer.byte(0)
		expect(b).to eql(0x61)
	end

	it "should return byte at index 2" do
		buffer = Buffer[0x61, 0x62, 0x63]
		b = buffer.byte(2)
		expect(b).to eql(0x63)
	end

	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer.byte(3)
		}.to raise_error(IndexError)
	end
end

describe "Buffer#bytes" do
	it "should return new array of bytes" do
		buffer = Buffer[0x61, 0x62, 0x63]
		a = buffer.bytes
		expect(a).to eql([0x61, 0x62, 0x63])
	end
end

describe "Buffer#each_byte" do
	it "should yield each byte" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect { |p|
			buffer.each_byte(&p)
		}.to yield_successive_args(0x61, 0x62, 0x63)
	end
end

describe "Buffer#slice" do
	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer.slice(-1, 2)
		}.to raise_error(IndexError)
	end

	it "should return new buffer with slice of bytes from index 0" do
		buffer = Buffer[0x61, 0x62, 0x63]
		slice = buffer.slice(0, 2)
		expect(slice).to eql(Buffer[0x61, 0x62])
	end

	it "should return new buffer with slice of bytes from index 1" do
		buffer = Buffer[0x61, 0x62, 0x63]
		slice = buffer.slice(1, 2)
		expect(slice).to eql(Buffer[0x62, 0x63])
	end

	it "should return new buffer with slice of bytes from index 2" do
		buffer = Buffer[0x61, 0x62, 0x63]
		slice = buffer.slice(2, 2)
		expect(slice).to eql(Buffer[0x63])
	end

	it "should raise error for index out of bounds" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect {
			buffer.slice(3, 2)
		}.to raise_error(IndexError)
	end
end

describe "Buffer#slices" do
	it "should return new array of slices" do
		buffer = Buffer[0x61, 0x62, 0x63]
		a = buffer.slices(2)
		expect(a).to eql([Buffer[0x61, 0x62], Buffer[0x63]])
	end
end

describe "Buffer#each_slice" do
	it "should yield each slice" do
		buffer = Buffer[0x61, 0x62, 0x63]
		expect { |p|
			buffer.each_slice(2, &p)
		}.to yield_successive_args(Buffer[0x61, 0x62], Buffer[0x63])
	end
end
