setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-ddev-vite-sidecar
  mkdir -p $TESTDIR
  export PROJNAME=test-ddev-vite-sidecar
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

start_dev_server() {
  # Start dev server in the background to be able to continue test
  screen -d -m ddev vite
  sleep 5

  # Wait maximum 3s until vite is ready for requests
  # for _ in `seq 1 12`; do
  #   echo -n .
  #   if ddev exec nc -z localhost 5173; then
  #     return
  #   fi
  #   sleep 0.25
  # done
}

error_checks() {
  ddev exec "curl -s -D - -o /dev/null https://vite.${PROJNAME}.ddev.site/@vite/client" | grep "HTTP/2 502"
  ddev exec "curl -s https://vite.${PROJNAME}.ddev.site/@vite/client" | grep "<h1>vite not running</h1>"
}

health_checks() {
  ddev exec "curl -s -D - -o /dev/null https://vite.${PROJNAME}.ddev.site/@vite/client" | grep "HTTP/2 200"
  # Test if vite can serve hidden files from node_modules
  ddev exec "curl -s https://vite.${PROJNAME}.ddev.site/node_modules/.vite/deps/_metadata.json" | grep "\"chunks\": {}"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from release and run dev server" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get s2b/ddev-vite-sidecar with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  VITE_PACKAGE_MANAGER=npm ddev get s2b/ddev-vite-sidecar
  ddev restart >/dev/null
  ddev exec npm i vite
  error_checks
  touch index.html
  start_dev_server
  health_checks
}

@test "Npm: install from directory and run build" {
  set -eu -o pipefail
  cd ${TESTDIR}
  VITE_PACKAGE_MANAGER=npm ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec npm install -D vite
  touch index.html
  ddev vite build --manifest
  test -f dist/index.html
  test -f dist/.vite/manifest.json
}

@test "Yarn: install from directory and run build" {
  set -eu -o pipefail
  cd ${TESTDIR}
  VITE_PACKAGE_MANAGER=yarn ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec yarn add -D vite
  touch index.html
  ddev vite build --manifest
  test -f dist/index.html
  test -f dist/.vite/manifest.json
}

@test "Pnpm: install from directory and run build" {
  set -eu -o pipefail
  cd ${TESTDIR}
  VITE_PACKAGE_MANAGER=pnpm ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec npm install -g pnpm
  ddev exec pnpm add -D vite
  touch index.html
  ddev vite build --manifest
  test -f dist/index.html
  test -f dist/.vite/manifest.json
}

@test "bun: install from directory and run build" {
  set -eu -o pipefail
  cd ${TESTDIR}
  VITE_PACKAGE_MANAGER=bun ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec npm install -g bun@latest
  ddev exec bun install -D vite
  touch index.html
  ddev vite build --manifest
  test -f dist/index.html
  test -f dist/.vite/manifest.json
}

@test "Nginx: install from directory and run dev server" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  VITE_PACKAGE_MANAGER=npm ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec npm i vite
  error_checks
  touch index.html
  start_dev_server
  health_checks
}

@test "Apache: install from directory and run dev server" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd)) for Apache" >&3
  VITE_PACKAGE_MANAGER=npm ddev get ${DIR}
  ddev restart >/dev/null
  ddev exec npm i vite
  error_checks
  touch index.html
  start_dev_server
  health_checks
}
