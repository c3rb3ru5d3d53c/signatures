threads=1
DATE=$(shell date '+%Y-%m-%d')
USER := $(shell whoami 2>/dev/null)
USER_ID := $(shell id -u ${USER})
GROUP_ID := $(shell id -g ${USER})

check-version:
	@echo "---check-version---"
	@if [ -z "${version}" ]; then \
		echo "[x] version parameter required" 1>&2; \
		exit 1; \
	fi

check-source-version:
	@echo "---check-source-version---"
	@if [ -z "${source_version}" ]; then \
		echo "[x] source_version parameter required" 1>&2; \
		exit 1; \
	fi

check-target-version:
	@echo "---check-target-version---"
	@if [ -z "${target_version}" ]; then \
		echo "[x] target_version parameter required" 1>&2; \
		exit 1; \
	fi

yara-docker: check-version
	@echo "---yara-docker---"
	@if [ -z "`docker images -q signatures:${version} 2> /dev/null`" ]; then \
		docker build --build-arg threads=${threads} -t signatures:${version} docker/yara/${version}/; \
	else \
		echo "[*] docker image for ${version} already completed"; \
	fi

yara-build: check-version
	@echo "---yara-build---"
	@mkdir -p build/yara/${version}/
	@rm -f build/yara/${version}/signatures.${version}.yara
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		mkdir -p build/yara/${version}/`dirname $${i}`; \
		cp $${i} build/yara/${version}/`dirname $${i}`/`basename $${i}`; \
		echo "include \"$${i}\"" | tee -a build/yara/${version}/signatures.${version}.yara; \
	done
	@cd build/yara/${version}/ && \
    	yarac --fail-on-warnings signatures.${version}.yara signatures.${version}.yarac

yara-docker-build:
	@echo "---yara-docker-build---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make yara-build version=${version}";

yara-bump-build: check-source-version check-target-version
	@echo "---yara-bump-build---"
	@mkdir -p build/yara/${target_version}/
	@rm -f build/yara/${target_version}/signatures.${target_version}.yara;
	@find build/yara/${source_version}/signatures/ -type f -name "*.${source_version}.yara" | while read i; do \
		target_file=`echo $${i} | sed "s/$$source_version/$$target_version/g"`; \
		target_dir=`dirname $${target_file}`; \
		mkdir -p $${target_dir}; \
		cp $${i} $${target_file}; \
		echo "include \"$${target_file}\"" | sed "s/build\/yara\/$$target_version\///" | tee -a build/yara/${target_version}/signatures.${target_version}.yara; \
	done
	@cd build/yara/${target_version}/ && \
			yarac --fail-on-warnings signatures.${target_version}.yara signatures.${target_version}.yarac

yara-docker-bump-build:
	@echo "---yara-docker-bump-build---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${target_version} bash -c "cd /mnt/; make yara-bump-build source_version=${source_version} target_version=${target_version}";

yara-stats: check-version
	@echo "---yara-stats---"
	@mkdir -p build/
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		scripts/yara/stats.sh $${i}; \
	done | tee -a build/stats.csv

yara-docker-stats:
	@echo "---yara-docker-stats---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make yara-stats version=${version}";

yara-version-bump: check-source-version check-target-version
	@echo "---yara-version-bump---"
	@find signatures/ -name "*.${source_version}.yara" | while read i; do \
		filepath=`echo $${i} | sed "s/\.${source_version}\.yara$$/\.${target_version}\.yara/"`; \
		echo "[-] `basename $${i}` to `basename $${filepath}`"; \
		cp $${i} $${filepath}; \
		echo "[*] `basename $${i}` to `basename $${filepath}`"; \
	done

yara-version-clean: check-version
	@echo "---yara-version-clean---"
	@find signatures/ -name "*.${version}.yara" | while read i; do \
			echo "[-] $${i}"; \
			rm -f $${i}; \
			echo "[*] $${i}"; \
	done

package-targets:
	@echo "---package-targets---"
	@find build/ -mindepth 2 -maxdepth 2 -type d | while read i; do \
		tar -czvf `dirname $${i}`/`basename $${i}`.tar.gz $${i}; \
	done

package: package-targets
	@echo "---package---"
	@cp -r build/ /tmp/signatures/;
	@mkdir -p build/
	@cd /tmp/; \
		tar --remove-files -czvf signatures.tar.gz signatures/; \
		mv signatures.tar.gz ${PWD}/build/signatures.tar.gz;

clean:
	@echo "---clean---"
	rm -rf build/

clean-docker:
	@echo "---clean-docker---"
	@docker stop $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rm $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rmi $(shell docker images -a -q) 2>/dev/null || echo > /dev/null
