#!/bin/sh

cd "${0%/*}"

export MPVD_TEST_ADDR="${MPVD_TEST_ADDR:-localhost}"
export MPVD_TEST_PORT="${MPVD_TEST_PORT:-6600}"

mkdir -p "${testdir:=${TMPDIR:-/tmp}/mpvd-tests}"
trap "rm -rf '${testdir}' ; kill 0" INT EXIT

for test in *; do
	[ -e "${test}/opts" ] || continue
	printf "Running test case '%s': " "${test##*/}"

	read -r fn < "${test}/song"
	mpv --quiet --input-ipc-server="${testdir}/mpvsock" \
		--loop inf "testdata/${fn}" >/dev/null &

	hy ../mpvd.hy -a "${MPVD_TEST_ADDR}" \
		-p "${MPVD_TEST_PORT}" "${testdir}/mpvsock" &

	./wait_port.hy "${MPVD_TEST_ADDR}" "${MPVD_TEST_PORT}"

	set -- $(cat "${test}/opts")
	mpc --host "${MPVD_TEST_ADDR}" --port "${MPVD_TEST_PORT}" \
		--wait "$@" 1>"${testdir}/output" 2>&1

	if ! cmp -s "${testdir}/output" "${test}/output"; then
		printf "FAIL: Output didn't match.\n\n"
		diff -u "${testdir}/output" "${test}/output"
		exit 1
	fi

	kill %1 %2; wait %1 %2
	printf "OK.\n"
done
