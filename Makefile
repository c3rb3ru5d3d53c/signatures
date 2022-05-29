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
	@mkdir -p dist/yara/${version}/
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		mkdir -p dist/yara/${version}/`dirname $${i}`; \
		cp $${i} dist/yara/${version}/`dirname $${i}`/`basename $${i}`; \
		echo "include \"$${i}\""; \
	done > dist/yara/${version}/signatures.${version}.yara
	@cd dist/yara/${version}/ && \
    	yarac --fail-on-warnings signatures.${version}.yara signatures.${version}.yarac

yara-docker-build:
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make yara-build version=${version}";

package:
	@find dist/ -mindepth 2 -maxdepth 2 -type d | while read i; do \
		tar -czvf `dirname $${i}`/`basename $${i}`.tar.gz $${i}; \
	done

clean:
	rm -rf dist/

clean-docker:
	@docker stop $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rm $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rmi $(shell docker images -a -q) 2>/dev/null || echo > /dev/null
