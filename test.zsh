#!/bin/zsh
# Watch for file changes and run isolated tests.
# 
# Vim will create a temporary backup file in the current folder unless nobackup
# and nowritebackup are both set. This will cause multiple CLOSE_WRITE events
# to occur. 

function runtests() {
	clear
	echo "## Testing: $1."
	time rdmd -Isource -main -unittest -debug -w "$1"
}

while true; do

	# Nothing like a nice clean terminal
	clear

	# Run the whole test suite
	time bundle exec rake spec

	inotifywait -qr -e close_write lib spec

	# Listen for events and run tests on any modified file
	#inotifywait -qr -me close_write --format "%f" source | while read file; do
		#find -name "$file" -amin "-1" | while read f; do
			#runtests "$f"
		#done
	#done

done
