#!/bin/bash



if [ -d  testdir ]; then
  (>&2 echo testdir already exists)
  mkdir temporarydir
  exit 2
fi

mkdir testdir

# does other stuff

echo Created testdir 
exit 0


