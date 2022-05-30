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

check-config:
	@echo "---check-config---"
	@if [ -z "${config}" ]; then \
		echo "[x] config parameter required" 1>&2; \
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

sigma-docker: check-version
	@echo "---sigma-docker---"
	@if [ -z "`docker images -q signatures:${version} 2> /dev/null`" ]; then \
		docker build --build-arg threads=${threads} -t signatures:${version} docker/sigma/${version}/; \
	else \
		echo "[*] docker image for ${version} already built"; \
	fi

sigma-build: check-version
	@echo "---sigma-build---"
	@mkdir -p build/sigma/${version}/
	@find signatures/ -type f -name "*.${version}.yml" | while read i; do \
		echo "[-] copy $${i}"; \
		mkdir -p build/sigma/${version}/`dirname $${i}`/; \
		cp $${i} build/sigma/${version}/`dirname $${i}`/`basename $${i}`; \
		echo "[*] copy $${i}"; \
	done
	@find signatures/ -type f -name "*.${version}.yml" | while read i; do \
		echo "echo '[-] logpoint $${i}'; sigmac -t logpoint -c docker/sigma/${version}/etc/sigma/config/logpoint-windows.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.logpoint\.sigma/'`; echo '[*] logpoint $${i}';";\
		echo "echo '[-] arcsight $${i}'; sigmac -t arcsight -c docker/sigma/${version}/etc/sigma/config/arcsight.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.arcsight\.sigma/'`; echo '[*] arcsight $${i}';";\
		echo "echo '[-] carbonblack $${i}'; sigmac -t carbonblack -c docker/sigma/${version}/etc/sigma/config/carbon-black.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.carbonblack\.sigma/'`; echo '[*] carbonblack $${i}';";\
		echo "echo '[-] crowdstrike $${i}'; sigmac -t crowdstrike -c docker/sigma/${version}/etc/sigma/config/crowdstrike.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.crowdstrike\.sigma/'`; echo '[*] crowdstrike $${i}';";\
		echo "echo '[-] qradar $${i}'; sigmac -t qradar -c docker/sigma/${version}/etc/sigma/config/qradar.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.qradar\.sigma/'`; echo '[*] qradar $${i}';";\
		echo "echo '[-] stix $${i}'; sigmac -t stix -c docker/sigma/${version}/etc/sigma/config/stix2.0.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.stix\.sigma/'`; echo '[*] stix $${i}';";\
		echo "echo '[-] netwitness $${i}'; sigmac -t netwitness -c docker/sigma/${version}/etc/sigma/config/netwitness.yml $${i} --output build/sigma/${version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.netwitness\.sigma/'`; echo '[*] netwitness $${i}';";\
	done | parallel --halt now,fail=1 -u -j ${threads} {}

sigma-bump-build: check-target-version check-source-version
	@echo "---sigma-build---"
	@mkdir -p build/sigma/${target_version}/
	@find signatures/ -type f -name "*.${source_version}.yml" | while read i; do \
		echo "[-] copy $${i}"; \
		mkdir -p build/sigma/${target_version}/`dirname $${i}`/; \
		cp $${i} build/sigma/${target_version}/`dirname $${i}`/`basename $${i}`; \
		echo "[*] copy $${i}"; \
	done
	@find signatures/ -type f -name "*.${source_version}.yml" | while read i; do \
		echo "echo '[-] logpoint $${i}'; sigmac -t logpoint -c docker/sigma/${target_version}/etc/sigma/config/logpoint-windows.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.logpoint\.sigma/'`; echo '[*] logpoint $${i}';";\
		echo "echo '[-] arcsight $${i}'; sigmac -t arcsight -c docker/sigma/${target_version}/etc/sigma/config/arcsight.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.arcsight\.sigma/'`; echo '[*] arcsight $${i}';";\
		echo "echo '[-] carbonblack $${i}'; sigmac -t carbonblack -c docker/sigma/${target_version}/etc/sigma/config/carbon-black.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.carbonblack\.sigma/'`; echo '[*] carbonblack $${i}';";\
		echo "echo '[-] crowdstrike $${i}'; sigmac -t crowdstrike -c docker/sigma/${target_version}/etc/sigma/config/crowdstrike.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.crowdstrike\.sigma/'`; echo '[*] crowdstrike $${i}';";\
		echo "echo '[-] qradar $${i}'; sigmac -t qradar -c docker/sigma/${target_version}/etc/sigma/config/qradar.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.qradar\.sigma/'`; echo '[*] qradar $${i}';";\
		echo "echo '[-] stix $${i}'; sigmac -t stix -c docker/sigma/${target_version}/etc/sigma/config/stix2.0.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.stix\.sigma/'`; echo '[*] stix $${i}';";\
		echo "echo '[-] netwitness $${i}'; sigmac -t netwitness -c docker/sigma/${target_version}/etc/sigma/config/netwitness.yml $${i} --output build/sigma/${target_version}/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.netwitness\.sigma/'`; echo '[*] netwitness $${i}';";\
	done | parallel --halt now,fail=1 -u -j ${threads} {}

sigma-docker-build: check-version
	@echo "---suricata-docker-test---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make sigma-build version=${version} threads=${threads}";

sigma-docker-bump-build: check-target-version
	@echo "---sigma-docker-bump-build---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${target_version} bash -c "cd /mnt/; make sigma-bump-build source_version=${source_version} target_version=${target_version} threads=${threads}";

sigma-download: check-version
	mkdir -p signatures/upstream/sigma/
	cd /tmp/; \
		rm -rf sigma/; \
		git clone https://github.com/SigmaHQ/sigma.git; \
		cd sigma/rules/; \
		find . -type f -name "*.yml" | while read i; do \
			mkdir -p ${PWD}/signatures/upstream/sigma/`dirname $${i}`/; \
			cp $${i} ${PWD}/signatures/upstream/sigma/`dirname $${i}`/`basename $${i} | sed 's/\.yml$$/\.${version}.yml/'`; \
		done; \
		rm -rf sigma/

suricata-docker: check-version
	@echo "---suricata-docker---"
	@if [ -z "`docker images -q signatures:${version} 2> /dev/null`" ]; then \
		docker build --build-arg threads=${threads} -t signatures:${version} docker/suricata/${version}/; \
	else \
		echo "[*] docker image for ${version} already built"; \
	fi

suricata-build: check-version
	@echo "---suricata-build---"
	@mkdir -p build/suricata/${version}/lua/
	@rm -f build/suricata/${version}/signatures.rules
	@find signatures/ -type f -name "*.${version}.lua" | while read i; do \
		echo "[-] $${i}"; \
		cp -n $${i} build/suricata/${version}/lua/`basename $${i}` || (echo "[x] ${version} file collision" 1>&2; exit 1); \
		echo "[*] $${i}"; \
	done
	@find signatures/ -type f -name "*.${version}.rules" | while read i; do \
		echo "[-] $${i}"; \
		mkdir -p build/suricata/${version}/`dirname $${i}`; \
		cp $${i} build/suricata/${version}/`dirname $${i}`/`basename $${i}`; \
		cat $${i} >> build/suricata/${version}/signatures.rules; \
		echo "[*] $${i}"; \
	done

suricata-test: check-version check-config
	@echo "---suricata-test---"
	@suricata -T -vv --init-errors-fatal -c ${config} -S build/suricata/${version}/signatures.rules || exit 1

suricata-docker-test: check-version
	@echo "---suricata-docker-test---"
	@docker run \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make suricata-test version=${version} config=/etc/suricata/suricata.yaml";

suricata-docker-build: check-version
	@echo "---suricata-docker-build---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${version} bash -c "cd /mnt/; make suricata-build version=${version}";

yara-docker: check-version
	@echo "---yara-docker---"
	@if [ -z "`docker images -q signatures:${version} 2> /dev/null`" ]; then \
		docker build --build-arg threads=${threads} -t signatures:${version} docker/yara/${version}/; \
	else \
		echo "[*] docker image for ${version} already built"; \
	fi

yara-lint: check-version
	@echo "---yara-lint---"
	@ find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		echo "./scripts/yara/lint.sh $${i};"; \
	done | parallel --halt now,fail=1 -u -j ${threads} {}

yara-build: check-version yara-lint
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

yara-docker-build: check-version
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

yara-docker-bump-build: check-target-version
	@echo "---yara-docker-bump-build---"
	@docker run \
		-u ${USER_ID}:${GROUP_ID} \
		--rm \
		-v ${PWD}/:/mnt/ \
		-t signatures:${target_version} bash -c "cd /mnt/; make yara-bump-build source_version=${source_version} target_version=${target_version}";

stats-init:
	@mkdir -p build/
	@echo "created,updated,target,os,type,tlp,author,description,file" > build/stats.csv

stats-yara: check-version
	@echo "---yara-stats---"
	@mkdir -p build/
	@find signatures/ -type f -name "*.${version}.yara" | while read i; do \
		scripts/yara/stats.sh $${i}; \
	done | tee -a build/stats.csv

stats-final:
	@cat build/stats.csv | python -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' > build/stats.json

yara-docker-stats: check-version
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

clean: clean-upstream
	@echo "---clean---"
	@rm -rf build/

clean-upstream:
	@echo "---clean-upstream---"
	@rm -rf signatures/upstream/

clean-docker:
	@echo "---clean-docker---"
	@docker stop $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rm $(shell docker ps -a -q) 2>/dev/null || echo > /dev/null
	@docker rmi $(shell docker images -a -q) 2>/dev/null || echo > /dev/null
