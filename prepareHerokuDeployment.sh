#!/bin/bash

function get-dart-dependencies {
 echo "get-dart-dependencies"
 pub get || { echo 'get-dart-dependencies failed' ; exit 1; }
}

function build-dart {
 echo "build-dart"
 pub build || { echo 'build-dart failed' ; exit 1; }
}

function commit-changes {

	echo "commit-changes"
	git config --global user.email "support@drone.io"
	git config --global user.name "Drone Server"
	git status 
	git add .
	git commit -m "add compiled and prefixed files" || { echo 'commit-changes' ; exit 1; }

}

get-dart-dependencies 
build-dart
commit-changes