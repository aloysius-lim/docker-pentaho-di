tag = 5.3

build_dir = build
VPATH = docker:$(build_dir)

all: image

.PHONY: all images-test test test-* clean clean-*

$(build_dir):
	mkdir $(build_dir)

image: Dockerfile docker-entrypoint.sh carte_config_master.xml carte_config_slave.xml $(build_dir)
	docker build -t abtpeople/pentaho-di:$(tag) docker
	touch $(build_dir)/$@

images-test: image-test-kitchenpan

image-test-kitchenpan: test/docker-kitchenpan/Dockerfile test/docker-kitchenpan/.kettle/* \
		test/docker-kitchenpan/repo/* $(build_dir)
	docker build -t abtpeople/pentaho-di:$(tag)-test-kitchenpan test/docker-kitchenpan
	touch $(build_dir)/$@

test: image image-test-kitchenpan
	TAG=$(tag) bats test

clean: clean-image clean-images-test
	-rmdir $(build_dir)

clean-image:
	-docker rmi abtpeople/pentaho-di:$(tag)
	-rm $(build_dir)/image

clean-images-test: clean-image-test-kitchenpan

clean-image-test-kitchenpan:
	-docker rmi abtpeople/pentaho-di:$(tag)-test-kitchenpan
	-rm $(build_dir)/image-test-kitchenpan
