#!/bin/bash

# openclaw message send --channel telegram --target $TELEGRAM_ID --message "Test"

workspace=$PWD

for repo in issues/*; do
	name=${repo##*/}
	for issue in $repo/*; do
		log="$workspace/$issue/issue_details.log"
		if [ -f "$log" ]; then
			TITLE=$(jq -r '.title' "$log")
			openclaw message send --channel telegram --target $TELEGRAM_ID --message "$TITLE fix in progress..."
			cd $workspace/repositories/$name
			echo "Read and investigate $workspace/$issue/issue_details.log. Make the necessary fix. Periodically add github issue comment of your progress. When your done, update project version (pubsec.yaml, build.gradle, etc), commit and push." 
			if [ -d "$workspace/$issue" ]; then
				rm -rf $workspace/$issue
			fi
		fi
	done
done

cd $workspace


