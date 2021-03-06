#!/usr/bin/ruby

# -k: Keep all files.
# -h: help.

require 'erb'

# This program generates the OS package code based on the Puppet Modulefile.
#  Currently it only supports Fedora.

# Author::    Henk52  (mailto:henk52@users.noreply.github.com)
# Copyright:: Copyright (c) 2013 henk52.
# License::   Apache License, Version 2.0

# Required keys/metadata
f_arRequiredModulefileKeys = [
   "description",
   "name",
   "summary",
   "version",
                             ]
# Finding out what the absolute path for this script, is.
f_szScriptFullPath = File.expand_path(File.dirname(__FILE__))

arSplitPath = f_szScriptFullPath.split('/')

# TODO V exit on error if the array doesn't contain atleast 3 elements.
#    module_path/files/_pkg_gen

# remove the '_pkg_gen'
arSplitPath.pop

# remove the 'files' directory
arSplitPath.pop

# Create the new path string.
f_szAbsolutePathToModule = arSplitPath.join('/')

# Read the Modulefile into an array, on line per entry in the array.
arLinesRead = IO.readlines("#{f_szAbsolutePathToModule}/Modulefile")

# This hash will contain all the key/value entries in the Modulefile.
hModulefileInformation =  Hash.new()

# Var set when the loop is investigating multilines.
nHandleMultiline = 0

szKey = ""
szValue = ""
szQuoteCharacter = ""

# Go through each of the raw lines.
arLinesRead.each { |szRawLine|
  # remove the newline at the end and remove and starting or trailing white spaces.
  szLine = (szRawLine.chomp()).strip()

  # only handle the szLine if it is not a comment and it is not empty.
  if ( ( szLine !~ /^#/ ) && ( szLine !~ /^$/ ) ) then
    if ( nHandleMultiline == 0 ) then
      # Split on the first whitespace.
      (szKey, szSepparator, szValue) = szLine.partition(%r{\s+})
      # TODO Barf if first character, in szValue, isn't ' or ".
      szQuoteCharacter = szValue[0]

      # We don't know that we are in multiline but we are guessing.
      nHandleMultiline = 1
    else
      szValue += szLine
    end

    # puts "Length: #{szValue.length()}, Quoute: #{szQuoteCharacter}, Last char: #{szValue[szValue.length()-1]}"
    #    puts "  szValue=#{szValue}="
    if ( szValue[szValue.length()-1] == szQuoteCharacter ) then
      nHandleMultiline = 0
    end    
    
    # If we are no longer handling multiline, then save the key.
    if ( nHandleMultiline == 0 ) then
      #puts "Key: =#{szKey}=, Value: =#{szValue}="

      # replace all ' with " in szValue.
      hModulefileInformation[szKey] = szValue[1, szValue.length()-2]
    end
  end
}

nRequiredKeyMissing = 0

# Make sure all requiered fields are defined.
f_arRequiredModulefileKeys.each() { |szRequiredKey|
  if ( ! hModulefileInformation.has_key?(szRequiredKey) ) then
    puts "EEE Required key missing: '#{szRequiredKey}'"
    nRequiredKeyMissing += 1
  end
}

if ( nRequiredKeyMissing != 0 ) then
  # TODO N handle the 's' when missing keys is more than 1.
  puts "Please define the missing key(s) in the Modulefile: #{f_szAbsolutePathToModule}/Modulefile"
  exit(1)
end

szFileList = `find . -type f | grep -e files -e manifests -e spec -e tests -e Modulefile -e README | grep -v _pkg_gen | sort`
arTemporaryFileList = szFileList.split("\n")
arRelativeFileList = Array.new()
arTemporaryFileList.each { |szRawFileEntry|
  # Drop './' in the beginning and newline at the end.
  arRelativeFileList.push((szRawFileEntry[2..-1]).chomp)
}

szSpecTemplate = "#{f_szScriptFullPath}/rpm_spec.erb"

erb = ERB.new(File.read(szSpecTemplate))

#puts erb.result
# Write the rpm spec file.
File.open("#{f_szScriptFullPath}/rpm.spec", 'w') {|f| f.write(erb.result) }

`rpmbuild --define 'builddir /home/vagrant/testBuildroot' -bb #{f_szScriptFullPath}/rpm.spec`
