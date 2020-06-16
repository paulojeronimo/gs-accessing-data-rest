#!/usr/bin/env bash
set -euo pipefail
USE_HTTP=${USE_HTTP:-false}
API=http://localhost:8080

test-top-level-curl() {
  curl $API
}

test-top-level-http() {
  http $API
}

test-people-curl() {
  curl $API/people
}

test-people-http() {
  http $API/people
}

test-people-create-curl() {
  local firstName=$1
  local lastName=$2
  curl -i -H "Content-Type:application/json" \
    -d "{\"firstName\": \"$firstName\", \"lastName\": \"$lastName\"}" \
    $API/people
}

test-people-retrieve-curl() {
  local id=$1
  curl $API/people/$id
}

test-people-update-curl() {
  local id=$1
  local firstName=$2
  local lastName=$3
  curl -X PUT -H "Content-Type:application/json" \
    -d "{\"firstName\": \"$firstName\", \"lastName\": \"$lastName\"}" \
    $API/people/$id
}

test-people-patch-curl() {
  local id=$1
  local firstName=$2
  local lastName=$3
  curl -X PATCH -H "Content-Type:application/json" \
    -d "{\"firstName\": \"$firstName\", \"lastName\": \"$lastName\"}" \
    $API/people/$id
}

test-people-delete-curl() {
  local id=$1
  curl -X DELETE $API/people/$id
}

test-people-search-curl() {
  curl $API/people/search
}

test-people-search-findByLastName-curl() {
  local name="$1"
  curl $API/people/search/findByLastName?name="$name"
}

usage() {
  cat <<-EOF
	Usage:
	$ $0 <action> [parameters]
	Possible actions:
$(sed -n '/^test-.*-curl/p' client.sh | sed 's/test-\(.*\)-curl.*/\1/g' | cat -n -)
	EOF
  exit 0
}

run-test() {
  local tool=$1; shift
  local action=$1; shift || :
  type test-$action-$tool &> /dev/null || {
    echo "test-$action-$tool function not found!"
    exit 1
  }
  test-$action-$tool "${@:-}"
}

cd "`dirname "$0"`"
action="${1:-}"
shift || :
[ "$action" ] || usage
http_installed=true
$USE_HTTP && {
  which http &> /dev/null || {
    echo "Warning: http not found, install it first! (https://httpie.org)"
    echo "We'll fall back to curl ..."
    http_installed=false
  }
} || which curl &> /dev/null || { echo "Install curl!"; exit 1; }
if $USE_HTTP && $http_installed; then
  run-test http $action "${@:-}"
else
  run-test curl $action "${@:-}"
fi
