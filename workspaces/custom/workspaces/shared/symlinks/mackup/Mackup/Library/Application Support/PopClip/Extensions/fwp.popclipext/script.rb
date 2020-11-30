		#!/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby

		require 'cgi'

		url = "FMP://firstwave.inresonance.com/FW_PROJECTS.fmp12?script=GoToOrg[ID]&param={query}"
		query = ENV['POPCLIP_TEXT']
		url.sub!(/\{query\}/,CGI.escape(query))

		%x{open "#{url}"}
