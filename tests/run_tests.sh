#!/bin/sh

cd "${0%/*}"

export MPVD_TEST_ADDR="${MPVD_TEST_ADDR:-localhost}"
export MPVD_TEST_PORT="${MPVD_TEST_PORT:-6600}"

mkdir -p "${testdir:=${TMPDIR:-/tmp}/mpvd-tests}"
trap "rm -rf '${testdir}' ; kill 0" INT EXIT

for test in *; do
	[ -e "${test}/commands" ] || continue
	printf "Running test case '%s': " "${test##*/}"

	read -r fn < "${test}/song"
	sock="${testdir}/mpvsock"

	mpv --quiet --input-ipc-server="${sock}" \
		--pause --loop inf "testdata/${fn}" >/dev/null &
	hy ../mpvd.hy -a "${MPVD_TEST_ADDR}" \
		-p "${MPVD_TEST_PORT}" "${sock}" &

	./wait_port.hy "${MPVD_TEST_ADDR}" "${MPVD_TEST_PORT}"

	output="${testdir}/output"
	printf "" > "${output}"

	env -i PATH="$(pwd):${PATH}" \
		HOST="${MPVD_TEST_ADDR}" \
		PORT="${MPVD_TEST_PORT}" \
		sh "${test}/commands" >> "${output}"

	if ! cmp -s "${output}" "${test}/output"; then
		printf "FAIL: Output didn't match.\n\n"
		diff -u "${output}" "${test}/output"
		exit 1
	fi

	kill %1 %2; wait %1 %2
	printf "OK.\n"
done
