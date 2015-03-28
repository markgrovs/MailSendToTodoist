property apiToken : "INSERT TODOIST API TOKEN HERE"
property allProjects : {}
property defaultProjectName : "Inbox"
property appName : "Send to Todoist from Mac Mail"
property appDomain : "us.markgroves"


on alfred_script(q)
	
	set date_string to ""
	if q contains "d:" then
		-- pull out due date string
		set date_string to text ((offset of "d:" in q) + 2) thru -1 of q
		set q to text 1 thru ((offset of "d:" in q) - 2) of q
	end if
	log ("date_string: " & date_string)
	log ("query: " & q)
	-- Add need Todoist item based on Input
	set RS to my addItem(q, "", date_string)
	
	-- Retrieve link from Mail
	set link to my get_link()
	log "link: " & link
	
	-- Add link as a note in Todoist
	my addNote(RS, link)
	return q
	
end alfred_script


-- Slightly modified version of Efficient Computing's AppleScript: http://efficientcomputing.commons.gc.cuny.edu/2012/03/17/copy-email-message-in-mail-app-to-evernote-applescript/
on get_link()
	
	tell application "Mail"
		set prevTIDs to AppleScript's text item delimiters
		set clipcat to ""
		set format to "td"
		set seperator to ","
		set selectedMails to the selection
		repeat with theMessage in selectedMails
			
			--get information from message
			set theMessageDate to the date received of theMessage
			set theMessageSender to sender of theMessage
			set theMessageSubject to the subject of the theMessage
			set theMessageURL to "message://%3c" & theMessage's message id & "%3e"
			
			--make a short header
			set theHeader to the all headers of theMessage
			set theShortHeader to (paragraph 1 of theHeader & return & paragraph 2 of theHeader & return & paragraph 3 of theHeader & return & paragraph 4 of theHeader & return & return)
			
			--format the message to url
			
			set clipcat to clipcat & " " & theMessageURL & " (" & my replace_chars(theMessageSubject, "&", "-") & ")"
			
			
		end repeat
		
		
		
		set AppleScript's text item delimiters to "("
		set temp to every text item of clipcat
		set AppleScript's text item delimiters to "("
		set clipcat to temp as string
		
		set AppleScript's text item delimiters to prevTIDs
		--set the clipboard to clipcat
		--copy clipcat to stdout
		log "This Link: " & clipcat
		return clipcat
		
		
	end tell
	
end get_link


on addItem(itemContent, projectName, date_string)
	log "addItem()"
	
	if date_string is "" then
		set Response to my todoistRequest("addItem?priority=1&content=" & itemContent, apiToken)
	else
		set Response to my todoistRequest("addItem?priority=1&content=" & itemContent & "&date_string=" & date_string, apiToken)
	end if
	log "Response: " & Response
	return Response
	
end addItem


on addNote(itemID, noteContent)
	log "addNote()"
	
	my todoistRequest("addNote?item_id=" & itemID & "&content=" & noteContent, apiToken)
	
end addNote


on todoistRequest(request, token)
	log "todoistRequest()"
	
	tell application "JSON Helper"
		if request does not contain "?" then
			set fullRequest to request & "?token=" & token
		else
			set fullRequest to request & "&token=" & token
		end if
		
		set JSONResponse to fetch JSON from "http://todoist.com/API/" & fullRequest with cleaning feed
		
		if result is "" then error "Invalid or empty API response from " & request
		log (JSONResponse)
		set myID to |id| of JSONResponse
		log ("This is the ID :" & myID)
		return myID
	end tell
end todoistRequest


on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars



