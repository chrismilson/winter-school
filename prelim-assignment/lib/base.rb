class BasicObject
	NIX = ::Object.new

	def nix
		return NIX
	end

	def nix?
		return equal?(NIX)
	end

	def checkcast(s)
		return self
	end

	def not_nil!
		if nil?
			raise TypeError.new("unexpected nil")
		end
		return self
	end
end

class Class
	alias_method :__new__, :new

	def nil
		return nil
	end
end

class << self
	def each_manifest_name(dir)
		path = File.join(dir, "manifest.txt")
		lines = File.readlines(path)
		lines.each do |line|
			name = line.strip
			unless name.empty?
				yield name
			end
		end
		return
	end

	def load_manifest(dir)
		each_manifest_name(dir) do |name|
			path = File.join(dir, "ruby", name)
			if File.exist?(path)
				load(path)
			end
		end
		return
	end

	def load_parent_manifest(dir)
		load_manifest(File.dirname(dir))
		return
	end
end
