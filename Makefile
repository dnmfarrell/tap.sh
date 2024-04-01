lint:
	shellcheck tap.sh
	shellcheck -x ./tap.sh tests/*.sh
	shellcheck -x ./tap.sh examples/hello/*.sh
	shfmt -w **/*.sh

test:
	prove ./tests/*

.PHONY: lint test
