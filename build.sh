#! /bin/bash

set -xue

time docker build --pull --network=host \
	--build-arg user=`id -nu` \
	--build-arg group=`id -ng` \
	--build-arg uid=`id -u` \
	--build-arg video_gid=`getent group video | cut -d: -f3` \
	--build-arg audio_gid=`getent group audio | cut -d: -f3` \
	-t anight/mattermost-desktop .

