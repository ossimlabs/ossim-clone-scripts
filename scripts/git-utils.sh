#!/bin/bash
###############################################################################
#
# got = git for OSSIM
#
# Convenience script for performing git operations on multiple OSSIMLABS repos.
# Up to four git parameters are handled, for example:
#
#    got commit -a
#    got log --oneline --graph
#
# Obviously, only commands that make sense to run on all repos will work. You
# can't commit a specific file for example.
#
# Run this script from ossimlabs parent directory (a.k.a. OSSIM_DEV_HOME)
#
###############################################################################

pushd `dirname $0` >/dev/null
export SCRIPT_DIR=`pwd -P`
pushd $SCRIPT_DIR/../.. >/dev/null
export ROOT_DIR=`pwd -P`
popd >/dev/null
popd >/dev/null

export OSSIMLABS_URL="https://github.com/ossimlabs"
export RADIANTBLUE_URL="https://github.com/radiantbluetechnologies"
export RADIANTBLUE_FILES=("ossim-msp ossim-private")
export OSSIMLABS_FILES=("omar omar-docs omar-disk-cleanup omar-config-server omar-eureka-server omar-turbine-server omar-zuul-server omar-base omar-ossim-base ossim ossim-ci ossim-gui ossim-oms ossim-planet ossim-plugins \
 ossim-vagrant ossim-video ossim-wms omar-avro omar-common omar-core omar-download omar-geoscript omar-hibernate-spatial omar-ingest-metrics\
 omar-jpip omar-mensa  omar-oms omar-openlayers omar-opir omar-ossimtools omar-raster omar-scdf-indexer omar-scdf-notifier-email omar-scdf-s3-extractor-filter omar-scdf-s3-filter omar-scdf-s3-uploader omar-scdf-stager omar-scdf-sqs omar-scdf-file-parser omar-scdf-downloader omar-scdf-aggregator omar-scdf-extractor omar-security omar-service-proxy\
 omar-services omar-sqs omar-stager omar-superoverlay omar-ui omar-video omar-wcs omar-wfs omar-oldmar omar-wms omar-wmts\
 three-disa tlv omar-scdf omar-scdf-stager omar-scdf-aggregator omar-scdf-sqs omar-scdf-extractor omar-scdf-zookeeper omar-scdf-kafka\
 omar-scdf-indexer omar-scdf-notifier-email omar-scdf-server omar-scdf-file-parser omar-scdf-downloader omar-scdf-s3-uploader omar-scdf-s3-filter \
 omar-scdf-s3-extractor-filter")


function checkoutFile {
    git clone $* 
}

function gitCommandOnRepo {
    repoRelativePath=$1
    command=$2
    echo "Entering directory $STARTING_DIRECTORY/$repoRelativePath"
    if [ -d $ROOT_DIR/$repoRelativePath ] ; then
      pushd $ROOT_DIR/$repoRelativePath
      git $command
      echo "Going back to directory $STARTING_DIRECTORY"
      echo
      popd > /dev/null
    else
      echo "Directory ${repoRelativePath} does not exist...Skipping directory"
    fi
}

function checkoutRepos {
    for file in $RADIANTBLUE_FILES ; do
      if [ ! -e $file ] ; then
        checkoutFile $RADIANTBLUE_URL/$file  $file
      fi
    done

    for file in $OSSIMLABS_FILES ; do
      if [ ! -e $file ] ; then
        checkoutFile $OSSIMLABS_URL/$file $file
      fi
    done
}

function gitCommandOnRepos {
    for file in $RADIANTBLUE_FILES ; do
      if [ -e $file ] ; then
        gitCommandOnRepo $file $1
      fi
    done

    for file in $OSSIMLABS_FILES ; do
      if [ -e $file ] ; then
        gitCommandOnRepo $file $1
      fi
    done
}


if [[ $1 == "checkout" || $1 == "CHECKOUT" ]]; then
    echo "ABOUT TO CHECKOUT REPOSITORIES"
    checkoutRepos
elif [[ $1 == "pull" || $1 == "PULL" ]]; then
    echo "ABOUT TO PULL REPOS"
    gitCommandOnRepos pull
elif [[ $1 == "status"  || $1 == "STATUS" ]]; then
    echo "ABOUT TO CHECK STATUS OF REPOS"
    gitCommandOnRepos status
else
    echo "Usage: git-utils.sh <command>"
    echo "commands: "pull" OR "checkout" OR "status""
fi
