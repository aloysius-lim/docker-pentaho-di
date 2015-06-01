tags = 5.2 5.3
latest = 5.3

build_dir = build
VPATH = docker:$(build_dir)

all: images

.PHONY: all images images-test test test-* clean clean-*

$(build_dir):
	mkdir $(build_dir)

images: $(tags:%=image-%)

image-%: %.Dockerfile docker-entrypoint.sh carte_config_master.xml carte_config_slave.xml $(build_dir)
	docker build -t abtpeople/pentaho-di:$* -f docker/$*.Dockerfile docker
	touch $(build_dir)/$@

images-test: $(tags:%=image-test-kitchenpan-%)

image-test-kitchenpan-%: test/docker-kitchenpan/%.Dockerfile test/docker-kitchenpan/.kettle/* \
		test/docker-kitchenpan/repo/* $(build_dir)
	docker build -t abtpeople/pentaho-di:$*-test-kitchenpan -f test/docker-kitchenpan/$*.Dockerfile test/docker-kitchenpan
	touch $(build_dir)/$@

test: test-carte_default test-carte_custom test-pan test-kitchen

test-carte_default: $(tags:%=test-carte_default-%)

test-carte_default-%: image-%
	IMAGE=abtpeople/pentaho-di:$* bats test/carte_default.bats

test-carte_custom: $(tags:%=test-carte_custom-%)

test-carte_custom-%: image-%
	IMAGE=abtpeople/pentaho-di:$* bats test/carte_custom.bats

test-pan: $(tags:%=test-pan-%)

test-pan-%: image-test-kitchenpan-%
	IMAGE=abtpeople/pentaho-di:$*-test-kitchenpan bats test/pan.bats

test-kitchen: $(tags:%=test-kitchen-%)

test-kitchen-%: image-test-kitchenpan-%
	IMAGE=abtpeople/pentaho-di:$*-test-kitchenpan bats test/kitchen.bats

clean: clean-images clean-images-test
	-rmdir $(build_dir)

clean-images: $(tags:%=clean-image-%)

clean-image-%:
	-docker rmi abtpeople/pentaho-di:$*
	-rm $(build_dir)/image-$*

clean-images-test: $(tags:%=clean-image-test-kitchenpan-%)

clean-image-test-kitchenpan-%:
	-docker rmi abtpeople/pentaho-di:$*-test-kitchenpan
	-rm $(build_dir)/image-test-kitchenpan-$*
