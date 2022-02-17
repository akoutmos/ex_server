.PHONY: build

build:
	rm -rf _build && \
	MIX_ENV=dev mix assets.deploy && \
  MIX_ENV=prod mix clean && \
	MIX_ENV=prod mix compile && \
	mix version && \
  MIX_ENV=prod mix archive.build -o archives/ex_server-$$(mix version).ez
