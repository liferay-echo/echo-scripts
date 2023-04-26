#!/bin/sh

whtype()
{
	echo Content-Type: text/plain;charset=utf-8
	echo Status: $1
	echo
	echo $2
}

[ $REQUEST_METHOD != POST ] && whtype 405 "? post" && exit 1

whhome=/sdf/udd/r/rubenpulido
whconf=$whhome/.wh-tango

[ ! -f $whconf/whtoken ] && whtype 500 "? whtoken" && exit 1

[ $HTTP_X_GITHUB_EVENT != pull_request ] && whtype 200 "i ev $HTTP_X_GITHUB_EVENT" && exit 0

set -- `jq -r '[.action, .pull_request.comments_url]|@tsv'`

[ $1 != opened ] && whtype 200 "i ac $1" && exit 0

whtype 200 "Ok"

token=`cat $whconf/whtoken`

whcomment()
{
	echo "dbg: $1::$2"
	curl -X POST -u $token -H "Accept: application/vnd.github.v3+json" $1 -d "{\"body\": \"$2\"}" 
}

whcomment $2 "Thank you for submitting this PR. 👏\n\nLPS components have been transferred to the Echo team. Please submit your PR to liferay-echo"
whcomment $2 "ci:close"

