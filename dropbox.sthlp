{smcl}
{hline}
help for {hi:dropbox}
{hline}
{title: Command to find Dropbox directory}

{p 8 27}
{cmd:dropbox}
[, {cmd:NOCD}] 


{title:Description}
{p} Services such as Dropbox have made data sharing easier. They can complicate do file sharing because Dropbox will be located in different places for different users.
{cmd:dropbox} searches for a user's main dropbox directory and switches to that directory. From there, users can use relative paths to move between their shared folders. {p_end}

{title:Options}

{p 0 4}
{cmd:NOCD} tells Stata not to change to the dropbox directory.
{p_end}

{title:Saved results}

The program stores the dropbox directory in {inp:r(db)}.

{title:Authors} 
 
	{browse "rhicks@princeton.edu":Raymond Hicks} 
	Niehaus Center for Globalization and Governance, Princeton University 
  
	{browse "http://scholar.harvard.edu/dtingley":Dustin Tingley} 
	Government Department, Harvard University
  
Email {browse "mailto:rhicks@princeton.edu":rhicks@princeton.edu} if you observe any problems. 
