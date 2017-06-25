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
export RADIANTBLUE_FILES=("cucumber-oc2s isa omar-merge-to-master o2-paas ossim-msp ossim-private")
export OSSIMLABS_FILES=("o2-delivery omar-git-mirror ossim-src omar omar-docs omar-disk-cleanup omar-config-server omar-eureka-server omar-turbine-server omar-zuul-server omar-base omar-ossim-base ossim ossim-ci ossim-gui ossim-oms ossim-planet ossim-plugins \
 ossim-vagrant ossim-video ossim-wms omar-avro omar-common omar-core omar-download omar-geoscript omar-hibernate-spatial omar-ingest-metrics\
 omar-jpip omar-mensa  omar-oms omar-openlayers omar-opir omar-ossimtools omar-raster omar-scdf-indexer omar-scdf-notifier-email omar-scdf-s3-extractor-filter omar-scdf-s3-filter omar-scdf-s3-uploader omar-scdf-stager omar-scdf-sqs omar-scdf-file-parser omar-scdf-downloader omar-scdf-aggregator omar-scdf-extractor omar-security omar-service-proxy\
 omar-services omar-sqs omar-stager omar-superoverlay omar-ui omar-video omar-wcs omar-wfs omar-oldmar omar-wms omar-wmts\
 three-disa tlv omar-scdf omar-scdf-stager omar-scdf-aggregator omar-scdf-sqs omar-scdf-extractor omar-scdf-zookeeper omar-scdf-kafka\
 omar-scdf-indexer omar-scdf-notifier-email omar-scdf-server omar-scdf-file-parser omar-scdf-downloader omar-scdf-s3-uploader omar-scdf-s3-filter \
 omar-scdf-s3-extractor-filter")


function cloneFile {
    git clone $* 
}

function gitCommandOnRepo {
    repoRelativePath=$1
#    command=$2
    echo "Entering directory $ROOT_DIR/$repoRelativePath"
    if [ -d $ROOT_DIR/$repoRelativePath ] ; then
      pushd $ROOT_DIR/$repoRelativePath
#      git $command
      git ${@:2}
      echo "Going back to directory $ROOT_DIR"
      echo
      popd > /dev/null
    else
      echo "Directory ${ROOT_DIR} does not exist...Skipping directory"
    fi
}

function cloneRepos {
    for file in $RADIANTBLUE_FILES ; do
      if [ ! -e $file ] ; then
        cloneFile $RADIANTBLUE_URL/$file  $file
      else
        echo "Repo $file already exists"
      fi
    done

    for file in $OSSIMLABS_FILES ; do
      if [ ! -e $file ] ; then
        cloneFile $OSSIMLABS_URL/$file $file
      else
        echo "Repo $file already exists"
      fi
    done
}

function gitCommandOnRepos {
      for file in $RADIANTBLUE_FILES ; do
        if [ -e $file ] ; then
          gitCommandOnRepo $file $*
        fi
      done

      for file in $OSSIMLABS_FILES ; do
        if [ -e $file ] ; then
          gitCommandOnRepo $file $*
        fi
      done
}
if [ $# -le 0 ] ; then
     echo "Usage: git-utils.sh <command> <args>"
     echo "  commands: pull | checkout | status "
     echo "  args: Any additional valid git arguments"
     echo "Usage 2: git-utils.sh <repo> <command> <args>"
     echo "  commands: Any supported git command"
     echo "  args: Any additional valid git arguments"
else
  if [[ $1 == "clone" || $1 == "clone" ]]; then
     echo "ABOUT TO clone REPOSITORIES"
     cloneRepos $*
  elif [[ $1 == "checkout" ]]; then
     echo "ABOUT TO CHECKOUT branch ${@:2}"
     gitCommandOnRepos $*
  elif [[ $1 == "pull" ]]; then
     echo "ABOUT TO PULL REPOS"
     gitCommandOnRepos $*
  elif [[ $1 == "status"  || $1 == "STATUS" ]]; then
     echo "ABOUT TO CHECK STATUS OF REPOS"
     gitCommandOnRepos $*
  else
     gitCommandOnRepo $*
  fi
fi