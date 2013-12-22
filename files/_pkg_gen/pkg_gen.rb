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

nHandleMultiline = 0

szKey = ""
szValue = ""
szQuoteCharacter = ""

arLinesRead.each { |szRawLine|
  # remove the newline at the end and remove and starting or trailing white spaces.
  szLine = (szRawLine.chomp()).strip()

  # only handle the line if it is not a comment and it is not empty.
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

    puts "Length: #{szValue.length()}, Quoute: #{szQuoteCharacter}, Last char: #{szValue[szValue.length()-1]}"
#    puts "  szValue=#{szValue}="
    if ( szValue[szValue.length()-1] == szQuoteCharacter ) then
      nHandleMultiline = 0
    end    
    
    # If we are no longer handling multiline, then save the key.
    if ( nHandleMultiline == 0 ) then
      puts "Key: =#{szKey}=, Value: =#{szValue}="
      # replace all ' with " in szValue.
      hModulefileInformation[szKey] = szValue
    end
  end
}
