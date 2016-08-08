#!/bin/bash
#
# docker-build.sh creates containers for building each component of traffic_control with
# all needed dependencies.  Once the build is complete, all rpms are copied into the "dist"
# directory in the current directory.
#
# Usage: docker-build.sh [<options>]
# Options:
#    -r <gitrepo> git repository to clone from (defaults to value of GITREPO env variable or
#		  `https://github.com/Comcast/traffic_control').  Can be a URI or local directory.
#    -b <branch>  branch (or tag) in repository to checkout (defaults to value of BRANCH env variable or `master')
#    -c           clean images after completion (default is not to clean)
#    -d <dir>     directory to copy build artifacts (default is ./dist)

export GITREPO="${GITREPO:-https://github.com/Comcast/traffic_control}"
export BRANCH="${BRANCH:-master}"
dist="./dist"
cleanup=

while getopts :r:b:cd: opt
do
	case $opt in
		r)
			GITREPO="$OPTARG"
			;;
		b)
			BRANCH="$OPTARG"
			;;
		c)
			cleanup=1
			;;
		d)
			dist="$OPTARG"
			;;
		*) 
			echo "Invalid option: $opt"
			exit 1;
			;;
	esac
done
shift $((OPTIND-1))

# anything remaining is list of projects to build
projects="${@:-traffic_ops traffic_monitor traffic_router traffic_stats traffic_portal}"

# if repo is local directory, get absolute path
if [[ -d $GITREPO ]]
then
	GITREPO=$(cd $GITREPO && pwd)
fi

# Get absolute path to dist dir
mkdir -p $dist || exit 1
dist=$(cd $dist && pwd)

cleanmsg=$([[ $cleanup ]] && echo "be cleaned up" || echo "not be cleaned up")
cat <<-ENDMSG
	********************************************************
	
	Building from git repository '$GITREPO' branch '$BRANCH'
	Artifacts will be delivered to '$dist'
	New docker images will $cleanmsg

	Projects to build: $projects
	********************************************************

ENDMSG

# sub-projects to build

image_exists() {
	docker history --quiet $1 >/dev/null 2>&1
	return $?
}

# collect image names for later cleanup
images=
createBuilders() {
	# topdir=.../traffic_control
	local topdir=$(cd "$( echo "${BASH_SOURCE[0]%/*}" )/.."; pwd)

	for p in $projects
	do
		local image=$p/build
		if ! image_exists $image
		then
			docker build --tag $image "$topdir/$p/build"
			images="$images $image"
		fi
	done
}

runBuild() {

	# Check if gitrepo is a local directory to be provided as a volume
	if [[ -d $GITREPO ]]
	then
		vol="-v $GITREPO:$GITREPO"
	fi
	mkdir -p dist
	for p in $projects
	do
		docker run $vol $p/build
		local id=$(docker ps --latest --quiet)
		docker cp $id:/vol/traffic_control/dist ./dist && docker rm $id
	done
}

createBuilders
runBuild

echo "rpms created: "
ls -l "$dist/."
