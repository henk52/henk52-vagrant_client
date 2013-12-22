#!/usr/bin/ruby

f_szScriptFullPath = File.expand_path(File.dirname(__FILE__))

arSplitPath = f_szScriptFullPath.split('/')

# reverse the array in place.
#arSplitPath.reverse!

# TODO V exit on error if the array doesn't contain atleast 3 elements.
#    module_path/files/_pkg_gen

# remove the '_pkg_gen'
arSplitPath.pop

# remove the 'files' directory
arSplitPath.pop

f_szAbsolutePathToModule = arSplitPath.join('/')

arLinesRead = IO.readlines("#{f_szAbsolutePathToModule}/Modulefile")

hModulefileInformation =  Hash.new()

arLinesRead.each { |szRawLine|
  # remove the newline at the end and remove and starting or trailing white spaces.
  szLine = (szRawLine.chomp()).strip()

  # only handle the line if it is not a comment and it is not empty.
  if ( ( szLine !~ /^#/ ) && ( szLine !~ /^$/ ) ) then
#    (szKey, szValue) = szLine.split(%r{\s+})
    (szKey, szSepparator, szValue) = szLine.partition(%r{\s+})
puts "Key: =#{szKey}=, Value: =#{szValue}="
    # replace all ' with " in szValue.
    hModulefileInformation[szKey] = szValue.gsub(/'/, '"')
#    puts hModulefileInformation[szKey]
  end
}
