# add topr service to launchd

add plist file to `~/Library/LaunchAgents/` because:
- it using `~/gopath/bin/topr` and the $HOME belongs to this user.
- And the log file is `~/top_surveillance.log` also belongs to this user.
