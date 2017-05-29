#!/usr/bin/env ruby

dir = Dir.pwd

require(File.join(dir, "lib", "quickspec.rb"))

$: << File.join(dir, "lib")
$: << File.join(dir, "spec")

pattern = "**/*_spec.{ir,rb}"

Dir["spec/#{pattern}"].each do |path|
	load(path)
end

exit(QuickSpec.status)
