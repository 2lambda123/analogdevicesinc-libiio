#!/bin/sh -xe

is_deployable_travis_ci_run() {
	# Don't deploy on a Coverity build
	[ -z "${COVERITY_SCAN_PROJECT_NAME}" ] || return 1

	# If we don't have SSH keys, don't bother
	[ -n "${ENCRYPTED_KEY}" ] || return 1
	[ -n "${ENCRYPTED_IV}" ] || return 1
}

get_ldist() {
	case "$(uname)" in
	Linux*)
		if [ ! -f /etc/os-release ] ; then
			if [ -f /etc/centos-release ] ; then
				echo "centos-$(sed -e 's/CentOS release //' -e 's/(.*)$//' \
					-e 's/ //g' /etc/centos-release)-$(uname -m)"
				return 0
			fi
			ls /etc/*elease
			[ -z "${OSTYPE}" ] || {
				echo "${OSTYPE}-unknown"
				return 0
			}
			echo "linux-unknown"
			return 0
		fi
		. /etc/os-release
		if ! command dpkg --version >/dev/null 2>&1 ; then
			echo $ID-$VERSION_ID-$(uname -m)
		else
			echo $ID-$VERSION_ID-$(dpkg --print-architecture)
		fi
		;;
	Darwin*)
		echo "darwin-$(sw_vers -productVersion)"
		;;
	*)
		echo "$(uname)-unknown"
		;;
	esac
	return 0
}

__brew_install_or_upgrade() {
	brew install $1 || \
		brew upgrade $1 || \
		brew ls --version $1
}

brew_install_or_upgrade() {
	while [ -n "$1" ] ; do
		__brew_install_or_upgrade "$1" || return 1
		shift
	done
}

upload_file_to_swdownloads() {
	if [ "$#" -ne 4 ] ; then
		echo "skipping deployment of something"
		echo "send called with $@"
		return 1
	fi

	if [ "x$1" = "x" ] ; then
		echo no file to send
		return 1
	fi

	if [ ! -r "$1" ] ; then
		echo "file $1 is not readable"
		ls -l $1
		return 1
	fi

	if [ -n "$TRAVIS_PULL_REQUEST_BRANCH" ] ; then
		local branch=$TRAVIS_PULL_REQUEST_BRANCH
	else
		local branch=$TRAVIS_BRANCH
	fi

	# Temporarily disable tracing from here
	set +x

	local LIBNAME=$1
	local FROM=$2
	local FNAME=$3
	local EXT=$4

	local TO=${branch}_${FNAME}
	local LATE=${branch}_latest_${LIBNAME}${LDIST}${EXT}
	local GLOB=${DEPLOY_TO}/${branch}_${LIBNAME}-*

	if curl -m 10 -s -I -f -o /dev/null http://swdownloads.analog.com/cse/travis_builds/${TO} ; then
		local RM_TO="rm ${TO}"
	fi

	if curl -m 10 -s -I -f -o /dev/null http://swdownloads.analog.com/cse/travis_builds/${LATE} ; then
		local RM_LATE="rm ${LATE}"
	fi

	echo attemting to deploy $FROM to $TO
	echo and ${branch}_${LIBNAME}${LDIST}${EXT}
	ssh -V

	mkdir -p build

	cat > build/script${EXT} <<-EOF
		cd ${DEPLOY_TO}

		${RM_TO}
		put ${FROM} ${TO}
		ls -l ${TO}

		${RM_LATE}
		symlink ${TO} ${LATE}"
		ls -l ${LATE}
		bye
	EOF
	sftp ${EXTRA_SSH} -b build/script${EXT} ${SSHUSER}@${SSHHOST}

	# limit things to a few files, so things don't grow forever
	if [ "$3" = ".deb" ] ; then
		for files in $(ssh ${EXTRA_SSH} ${SSHUSER}@${SSHHOST} \
			"ls -lt ${GLOB}" | tail -n +100 | awk '{print $NF}')
		do
			ssh ${EXTRA_SSH} ${SSHUSER}@${SSHHOST} \
				"rm ${DEPLOY_TO}/${files}"
		done
	fi

	# Re-enable tracing
	set -x
}
