#!/bin/sh

whtype()
{
	echo Content-Type: text/plain;charset=utf-8
	echo Status: $1
	echo
	echo $2
}

[ $REQUEST_METHOD != POST ] && whtype 405 "? post" && exit 1

whhome=@HOME
whconf=$whhome/.wh

[ ! -f $whconf/whtoken ] && whtype 500 "? whtoken" && exit 1

[ $HTTP_X_GITHUB_EVENT != pull_request ] && whtype 200 "i ev $HTTP_X_GITHUB_EVENT" && exit 0

set -- `jq -r '[.action, .pull_request.comments_url, .pull_request.url + "/files", .pull_request.issue_url + "/labels", .pull_request.user.login]|@tsv'`

action=$1
comments_url=$2
files_url=$3
labels_url=$4
user=$5

[ "$action" != opened ] && whtype 200 "i ac $1" && exit 0

if grep -q ^"$user"$ "$whconf/users"
then
  whtype 200 "skipped user $user";
  exit 0;
fi

whtype 200 "Ok"

token=`cat $whconf/whtoken`

whlsext()
{
	curl -u $token -H "Accept: application/vnd.github.v3+json" $1 |
	jq -r '.[].filename|@text' |
	sed -e '/\./!d' -e 's/.*\.\([^.]*\)$/\1/' |
	sort -u
}

whlsname()
{
	curl -u $token -H "Accept: application/vnd.github.v3+json" $1 |
	jq -r '.[].filename|@text' |
	xargs -n 1 basename |
	sort -u
}

whlabel()
{
	tmp=`mktemp -t wh`
	cat >$tmp
	grep -F -l -x -f $tmp $whconf/$2/* |
	tr ' ' '_' |
	xargs -n 1 basename |
	tr '_' ' ' |
	awk 'BEGIN { printf "{\"labels\":[" } { printf "\"%s\",", $0 } END { printf "]}" }' |
	sed 's/,]}/]}/' |
	curl -X POST -u $token $1 -d @- >/dev/null
	rm $tmp
}

whlsext "$files_url" | whlabel "$labels_url" labels
whlsname "$files_url" | whlabel "$labels_url" file-name-labels
