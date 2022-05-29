threads=1
DATE=$(shell date '+%Y-%m-%d')
USER := $(shell whoami 2>/dev/null)
USER_ID := $(shell id -u ${USER})
GROUP_ID := $(shell id -g ${USER})

check-version:
	@if [ -z "${version}" ]; then \
		echo "[x] version parameter required" 1>&2; \
		exit 1; \
	fi

yara-docker: check-version
	@if [ -z "`docker images -q signatures:${version} 2> /dev/null`" ]; then \
		docker build --build-arg threads=${threads} -t signatures:${version} docker/yara/${version}/; \
	else \
		echo "[*] docker image for ${version} already completed"; \
	fi

yara-build: check-version
	@mkdir -p build/yara/${version}/
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		mkdir -p build/yara/${version}/`dirname $${i}`; \
		cp $${i} build/yara/${version}/`dirname $${i}`/`basename $${i}`; \
		echo "include \"$${i}\""; \
	done > build/yara/${version}/signatures.${version}.yara
	@cd build/yara/${version}/ && \
    	yarac --fail-on-warnings signatures.${version}.yara signatures.${version}.yarac

yara-docker-build:
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make yara-build version=${version}";

yara-stats: check-version
	@mkdir -p build/
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		scripts/yara/stats.sh $${i}; \
	done | tee -a build/stats.csv

yara-docker-stats:
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make yara-stats version=${version}";

package-targets:
	@find build/ -mindepth 2 -maxdepth 2 -type d | while read i; do \
		tar -czvf `dirname $${i}`/`basename $${i}`.tar.gz $${i}; \
	done

package: package-targets
	@cp -r build/ /tmp/signatures/;
	@mkdir -p build/
	@cd /tmp/; \
		tar --remove-files -czvf signatures.tar.gz signatures/; \
		mv signatures.tar.gz ${PWD}/build/signatures.tar.gz;

clean:
	rm -rf build/

clean-docker:
	@docker stop $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rm $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rmi $(shell docker images -a -q) 2>/dev/null || echo > /dev/null
