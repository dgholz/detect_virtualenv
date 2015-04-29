test:
	@find t -type d -print0 | xargs --null --no-run-if-empty vendor/bats/bin/bats --pretty
