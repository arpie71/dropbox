Dropbox is an ado file that will look for the Dropbox directory in the most common places users install Dropbox. 
It will start in the most commonly used location  (/users/`c(username)'/Dropbox for Windows and ~/Dropbox for Macs and Unix computers) and then search within the Documents directory and then the root directory to find Dropbox. 
The command will return the local Dropbox directory as r(db) and, unless the `nocd` option is specified, it will change the directory to a user's root Dropbox directory. 
From there, the relative paths of all users within Dropbox will be the same. The command also uses the username macro to look for the Dropbox directory. 

Version 2 of the command adds an `external` option that will search in secondary and external drives first before looking at the primary drive. The `nocd` option has also been adjusted so that a clickable link will appear in the Viewer.
