program define dropbox , rclass
syntax [, NOCD EXTERNAL]
 mata : st_rclear()

if "`external'"!="" {
    di "Searching external drives"
	if "`c(os)'" == "Windows" {
		local drives `=c(alpha)'
		local c = "c"
		local drives: list drives - c
		local remainingdrives "`drives'"
		foreach d of local drives {
			capture local slist : dir "`d':/" dirs "*" 
			if _rc!=0 {
				local remainingdrives: list remainingdrives - d 
			}
		 }
		 extdrives "`remainingdrives'" "`nocd'" ""
	}
	if "`c(os)'"~= "Windows" {
		local stop = ""
		foreach drive of newlist Volumes mnt media {
		
		if `"`stop'"'!="stop" {
			capture local drives : dir "/`drive'" dirs "*"
		if _rc==0 {
		di "Searching `drive'"
		local remainingdrives `"`drives'"'
		local excl `""Preboot""'
		local remainingdrives: list remainingdrives - excl
		foreach a of local remainingdrives {
			if `=ustrregexm("Macintosh HD","`a'")' {
				local remove `""`a'""'
				local remainingdrives: list remainingdrives - remove 
			}
		}
		foreach d of local drives {
			capture local slist : dir "/`drive'/`d'/" dirs "*" 
			if _rc!=0 {
				local remainingdrives: list remainingdrives - d 
			}
		}
		extdrives `"`remainingdrives'"' "`nocd'" "/`drive'"
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	local stop = "stop"
	exit
	}
		}
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	local stop = "stop"
	exit
	}
	
		}
	}
	if `"`remainingdrives'"'=="" {
			di as error "No external drives attached"   
			exit
	}
	}
	di "Dropbox not found on external drives. Searching in primary drive"
	}

*if "`external'"=="" {
	local _db = cond("`=c(os)'"=="Windows", "/users/`c(username)'", "~")
	* First, search main user directory
	format_dropbox2 "`_db'" `"`nocd'"'
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	exit
	}

	* Checking under user directory and documents subfolder
	format_dropbox2 `"`_db'/Documents"' `"`nocd'"'
	if !inlist("`=r(db)'","",".") {
		return local db "`=r(db)'"
		exit
	}
	
	 * Older Windows machines store documents folder in different places
	 * Checking those locations
	 if "`c(os)'" == "Windows" {
		* Check if c:/ exists on Windows
		mata: st_numscalar("OK", direxists("c:/"))
		if scalar(OK)==0 {
			di as error "C drive does not exist"
			exit 
		}
		capture local dropbox : dir "c:/" dir "*Dropbox*" , respectcase
		if _rc==0 & `"`dropbox'"'~="" {
			format_dropbox `"`_db'"' `"`dropbox'"' `"`nocd'"'
			return local db "`=r(db)'"
			exit
		}
	* Check other possible locations
	format_dropbox2 `"c:/documents and settings/`c(username)'/my documents/"' `"`nocd'"'
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	exit
	}

	format_dropbox2 `"c:/documents and settings/`c(username)'/documents/"' `"`nocd'"'
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	exit
	}

	format_dropbox2 `"`_db'/My Documents/"' `"`nocd'"'
	if !inlist("`=r(db)'","",".") {
	return local db "`=r(db)'"
	exit
	}

}
*}

	if inlist("`=r(db)'","",".") {
			di as error "Cannot find dropbox folder"   
			exit
	}

end

program define search_recurs , rclass
	args dirname searchterm basedir
	local slist ""
	capture local slist : dir "`basedir'/`dirname'/" dirs "*" , respectcase
	if `"`slist'"'!="" {
	if `: list searchterm in slist' {
	return local db "`basedir'/`dirname'"
	}
}
end

program define searchloop , rclass
	args dirlist searchterm basedir nocd
	gettoken l dirlist : dirlist
	while "`l'"!="" & missing(r(db)) {
		search_recurs `"`l'"' `"`searchterm'"' `"`basedir'"'
		gettoken l dirlist : dirlist
	} 
	if !missing(r(db)){
		if "`nocd'"=="" {
			cd "`=r(db)'/`searchterm'"
		}
		if `"`nocd'"'!=""{
		    local d "`=r(db)'/`searchterm'"
		    display `"{stata `"cd `"`d'"'"'}"'
		}		
		return local db `"`=r(db)'/`searchterm'"'
	} 
end

program define format_dropbox2 , rclass
	args dblink  nocd 
	capture local dropbox : dir "`dblink'" dir "*Dropbox*" , respectcase
	if _rc==0 & `"`dropbox'"'~="" {
		local dropbox : subinstr local dropbox `"""' "" , all
		if "`nocd'"=="" {
			cd `"`dblink'/`dropbox'"'
		}
		if `"`nocd'"'!=""{
		    local d "`dblink'/`dropbox'"
		    display `"{stata `"cd `"`d'"'"'}"'
		}
		return local db `"`dblink'/`dropbox'"'
	}
end

program def extdrives , rclass
args remainingdrives nocd drivetype
	foreach drive of local remainingdrives {
	    local _db = cond("`=c(os)'"=="Windows", "`drive':/", "/`drivetype'/`drive'/")
		local list : dir "`_db'" dirs "*" , respectcase
		local searchd  "Dropbox"
		format_dropbox2 `"`_db'"' `"`nocd'"'
		if !inlist("`=r(db)'","",".") {
			local stop = "`=r(db)'"
			return local db "`=r(db)'"
			exit
		}
		*di "`=r(db)'"
		searchloop `"`list'"' `searchd' `_db' `"`nocd'"'
		if !inlist("`=r(db)'","",".") {
			local stop = "`=r(db)'"
			return local db "`=r(db)'"
			exit
		}
		gettoken l list : list
		while inlist("`stop'",".","") {
			capture local sublist : dir "`_db'/`l'" dirs "*"
			if `"`sublist'"'!="" {
				local nextdir "`_db'/`l'"
				searchloop `"`sublist'"' `searchd' `"`nextdir'"' `"`nocd'"'
				local stop = "`=r(db)'"
					if !inlist("`=r(db)'",".","") {
						return local db "`=r(db)'"
						exit
					}
					foreach sl of local sublist {
					capture local sublist2 : dir "`_db'/`l'/`sl'" dirs "*"
					if `"`sl'"'!="" {
						local nextdir2 "`_db'/`l'"
						searchloop `"`sl'"' `searchd' `"`nextdir2'"' `"`nocd'"'
						local stop = "`=r(db)'"
					if !inlist("`=r(db)'",".","") {
						return local db "`=r(db)'"
						exit
					}
					}
				}
					if !inlist("`=r(db)'",".","") {
						return local db "`=r(db)'"
						exit
					}
			}	
			gettoken l list : list
			if "`l'"=="" {
				local stop = "None"
			}
		}
	}
end


