#
#  Makefile: Build rules for the Epichrome.
#
#  Copyright (C) 2022  David Marmor
#
#  https://github.com/dmarmor/epichrome
#
#  Full license at: http://www.gnu.org/licenses/ (V3,6/29/2007)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SHELL = /bin/bash

# BASIC INFO

APP:=Epichrome/Epichrome.app
SCAN_APP:=Epichrome/Epichrome\ Scan.app
LOGIN_APP:=Epichrome/Epichrome.app/Contents/Library/LoginItems/EpichromeLogin.app

NMH_ID:=org.epichrome.runtime

EXTN_ID_RELEASE:=ngbmbabjgimgbfobhfhjpfhpmpnhbeea
EXTN_ID_BETA:=cknkfdhlojihpopgbmoknioompcojicj

CODESIGN_IDENTITY:=$(shell cat private/codesign_identity.txt)

THISYEAR:=$(shell date '+%Y')

GITHUB_UPDATE_URL:=https:\/\/github.com\/dmarmor\/epichrome\/releases\/latest


# APP PATHS

APP_CT:=$(APP)/Contents
APP_RNTM:=$(APP_CT)/Resources/Runtime

PROGRESS_APP:=$(APP_RNTM)/Contents/Resources/EpichromeProgress.app
PROGRESS_CT:=$(PROGRESS_APP)/Contents

SCAN_CT:=$(SCAN_APP)/Contents

LOGIN_CT:=$(LOGIN_APP)/Contents


# APP NAMES

EPICHROME_DISPNAME:=Epichrome
EPICHROME_SHORTNAME:=$(EPICHROME_DISPNAME)
INSTALL_FOLDER:=$(EPICHROME_DISPNAME)
SCAN_DISPNAME:=Epichrome Scan
SCAN_SHORTNAME:=$(SCAN_DISPNAME)
LOGIN_DISPNAME:=Epichrome Login
LOGIN_SHORTNAME:=EpichromeLogin


# VERSION INFO

VERSION_INTERNAL:=$(shell source src/version.sh ; \
		if [[ '$(filter bump,$(MAKECMDGOALS))' ]] ; then \
			bumpedNum="$$(($$epiBuildNum + 1))" ; \
			sed -i '' -E 's/^epiBuildNum=.*$$/epiBuildNum='"$$bumpedNum"'/' src/version.sh ; \
			printf 'Bumped build number (%03d -> %03d)\n' "$$epiBuildNum" "$$bumpedNum" 1>&2 ; \
			epiBuildNum="$$bumpedNum" ; \
		fi ; \
		echo "$$epiVersion[$$(printf '%03d' "$$epiBuildNum")]")

ifeq ($(VERSION),)
VERSION:=$(shell if [[ '$(filter release package notarize notarize-check notarize-staple,$(MAKECMDGOALS))' ]] ; then \
			version='$(VERSION_INTERNAL)' ; \
			echo "$${version%[*}" ; \
		else \
			echo '$(VERSION_INTERNAL)' ; \
		fi)
endif
export VERSION

VERSIONMAJOR:=$(shell version='$(VERSION)' && echo "$${version%.*}")
VERSIONTEXT:=$(subst b, BETA ,$(VERSION))
VERSIONCODE:=$(shell scripts/versioncode.sh '$(VERSION_INTERNAL)')
ifeq ($(VERSIONCODE),FAIL)
$(error Unable to parse version number in version.sh)
endif

# target to clean app when switching between release and internal builds
CLEANVERSION:=$(shell if [[ -e $(APP_CT)/Resources/Scripts/version.sh ]] ; then \
				source $(APP_CT)/Resources/Scripts/version.sh ; \
				if [[ ( ( "$$epiVersion" = *']' ) && ( '$(VERSION)' != *']' ) ) || \
					( ( "$$epiVersion" != *']' ) && ( '$(VERSION)' = *']' ) ) ]] ; then \
					echo 'clean' ; \
				fi ; \
			fi)

MIN_OS:="$$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' '$(APP)/Contents/Resources/Runtime/Engine/Filter/Info.plist')"

BETA:=$(shell if [[ '$(VERSION)' =~ b ]] ; then echo _beta ; else echo '' ; fi)


# CHROMIUM ENGINE
# (Using Marmaduke build with Google APIs and Widevine from https://chromium.woolyss.com/)

# CHROMIUM:=$(shell ls Engines/Chromium* 2> /dev/null | sort -r | head -n 1)
# ifeq ($(CHROMIUM),)
# $(error Unable to find Chromium archive)
# endif
# ifneq ($(suffix $(CHROMIUM)),.tgz)
# ifneq ($(suffix $(CHROMIUM)),.zip)
# $(error Unrecognized file in Engines directory: $(CHROMIUM))
# endif
# CHROMIUM:=$(CHROMIUM:.zip=.tgz)
# endif
# CHROMIUM_VERSION:=$(shell if [[ '$(CHROMIUM)' =~ [0-9][0-9.]*[0-9] ]] ; then \
# 				echo "$${BASH_REMATCH[0]}" ; else echo ERROR ; fi)
# ifeq ($(CHROMIUM_VERSION),ERROR)
# $(error Unable to retrieve Chromium version from $(CHROMIUM))
# endif


# BRAVE ENGINE

BRAVEINFO:=$(shell scripts/updatebrave.sh Engines)
BRAVE:=$(shell braveinfo='$(BRAVEINFO)' ; echo "$${braveinfo%|*}")
BRAVE_VERSION:=$(shell braveinfo='$(BRAVEINFO)' ; echo "$${braveinfo\#*|}")
ifeq ($(BRAVE),)
$(error Unable to find Brave archive)
endif
ifeq ($(BRAVE_VERSION),ERROR)
$(error Unable to parse Brave version)
endif
ifneq ($(suffix $(BRAVE)),.tgz)
ifeq ($(suffix $(BRAVE)),.dmg)
BRAVE_SRC:=brave_dmg
BRAVE:=$(BRAVE:.dmg=.tgz)
else ifeq ($(suffix $(BRAVE)),.pkg)
BRAVE_SRC:=brave_pkg
BRAVE:=$(BRAVE:.pkg=.tgz)
else
$(error Unrecognized file in Engines directory: $(BRAVE))
endif
endif


# BETA/INTERNAL CONDITIONAL INFO

ifeq ($(shell if [[ ( ! '$(filter release package,$(MAKECMDGOALS))' ) || ( '$(BETA)' != '' ) ]] ; then \
			echo DEBUG ; \
		else \
			echo NODEBUG ; \
		fi),DEBUG)

DEBUG_SH:=1
LOGPRESERVE_SH:=9
BACKUPPRESERVE_SH:=9

ifeq ($(BETA),_beta)
EPICHROME_DISPNAME:=$(EPICHROME_DISPNAME) Beta
EPICHROME_SHORTNAME:=$(EPICHROME_SHORTNAME) Beta
SCAN_DISPNAME:=$(SCAN_DISPNAME) Beta
SCAN_SHORTNAME:=$(SCAN_SHORTNAME) ß
LOGIN_DISPNAME:=$(LOGIN_DISPNAME) Beta
LOGIN_SHORTNAME:=$(LOGIN_SHORTNAME) ß
INSTALL_FOLDER:=$(INSTALL_FOLDER) Beta
endif

else

DEBUG_SH:=
LOGPRESERVE_SH:=4
BACKUPPRESERVE_SH:=4

endif



# META-TARGETS

INTERMEDIATES:=\
	build/main.js \
	build/launch.js \
	build/engine/Brave \
	build/engine/Chromium \
	build/engine_tmp \
	build/engine_tmp/brave \
	build/engine_tmp/brave_dmg \
	build/engine_tmp/brave_pkg \
	build/engine_tmp/brave_recodesign.sh \
	build/engine_tmp/brave_signature.txt \
	build/engine_tmp/brave_entitlements.plist \
	build/fake.icns \
	build/fake.sh \
	build/scripts/postinstall \
	build/package \
	build/epichrome-$(VERSION)-main.plist \
	build/epichrome-$(VERSION)-dist.xml


PRECIOUS_INTERMEDIATES:=\
	build/icons/app.png \
	build/icons/app_beta.png \
	build/icons/app_core.png \
	build/icons/scan_app.png \
	build/icons/scan_app_beta.png \
	build/icons/login_app.png \
	build/icons/login_app_beta.png \
	build/icons/apptemplate_bg_white.png \
	build/icons/apptemplate_bg_gray.png \
	build/icons/apptemplate_bg_black.png \
	build/icons/apptemplate_shadow.png \
	build/icons/doctemplate_bg.png \
	build/icons/doctemplate_fg.png \
	build/icons/document.png \
	build/icons/document_beta.png \
	build/icons/epichrome.png \
	build/icons/epichrome_beta.png \
	build/icons/folder.png \
	build/icons/folder_beta.png \
	build/icons/app.icns \
	build/icons/app_beta.icns \
	build/icons/document.icns \
	build/icons/document_beta.icns \
	build/icons/epichrome.icns \
	build/icons/epichrome_beta.icns \
	build/icons/scan_app.icns \
	build/icons/scan_app_beta.icns \
	build/icons/login_app.icns \
	build/icons/login_app_beta.icns \
	build/icons/folder.icns \
	build/icons/folder_beta.icns \
	build/img/app_icon.png \
	build/img/app_icon_beta.png \
	build/img/epichrome_icon.png \
	build/epichrome-$(VERSION)-main.pkg \
	build/resources/background.png \
	build/resources/license.rtf \
	build/resources/readme.rtf \
	build/resources/welcome.rtf

.DELETE_ON_ERROR:

.PHONY: bump build release package clean no-clean clean-package clean-engine clean-all verify notarize notarize-staple

.PRECIOUS: $(PRECIOUS_INTERMEDIATES)

.INTERMEDIATE: main engine runtime progress-core scan-core login-core $(INTERMEDIATES) $(PRECIOUS_INTERMEDIATES)


# BUILD TARGETS (DEFAULT TARGET)

build: $(CLEANVERSION) $(APP) $(SCAN_APP)

release: build


# VERSION NUMBER MANAGEMENT TARGET

bump:
	@: #if [[ '$(filter-out bump,$(MAKECMDGOALS))' = '' ]] ; then $(MAKE) ; fi


# UTILITY TARGETS

clean:
	rm -rf $(APP) $(SCAN_APP)
	rm -rf build/main* build/runtime* build/engine build/engine_tmp build/resources $(INTERMEDIATES)
	@hdiutil detach build/dmg 2> /dev/null || true

no-clean:
	@:

clean-package:
	rm -f epichrome-*.pkg
	rm -rf build/resources build/epichrome-*.pkg build/epichrome-*.xml build/main* build/runtime* $(INTERMEDIATES)

clean-engine:
	rm -f $(BRAVE)

clean-all: clean clean-package clean-engine
	rm -rf build
	find . \( -name '*~' -or -name '.DS_Store' \) -exec rm {} \;

build/icons/%.icns: build/icons/%.png src/core.sh src/makeicon.sh src/makeicon.php
	@mkdir -p '$(dir $@)'
	iMakeIconScript='src/makeicon.php' ; \
	iIconTemplatePath='$(APP_CT)/Resources/Icons' ; \
	source 'src/makeicon.sh' ; \
	makeicon '$<' '$@' ; \
	if [[ "$$ok" ]] ; then cleanexit ; else exit 1 ; fi

build/icons/%.png: ../images/icons/%.psd
	@if [[ -d private/PNG.app ]] ; then \
		open -a "$$(cd private ; pwd)"/PNG.app '$<' ; \
		printf 'Waiting for Photoshop to finish converting $<...' ; \
		while [[ ( ! -e $(basename $<).png ) || ( $(basename $<).png -ot $< ) ]] ; do sleep 1 ; done ; \
		mtime=$$(stat -f '%m' $(basename $<).png) ; \
		while [[ "$$oldmtime" != "$$mtime" ]] ; do \
			sleep 1 ; \
			oldmtime="$$mtime" ; \
			mtime=$$(stat -f '%m' $(basename $<).png) ; \
		done ; \
		mv $(basename $<).png $@ ; \
		echo 'done!' ; \
	else \
		cmd=( sips --setProperty format png --out $@ $< ) ; \
		echo "$${cmd[@]}" ; "$${cmd[@]}" ; \
	fi


# PACKAGE BUILD
# (adapted from http://thegreyblog.blogspot.com/2014/06/os-x-creating-packages-from-command_2.html)

package: epichrome-$(VERSION).pkg

epichrome-$(VERSION).pkg: build/epichrome-$(VERSION)-main.pkg build/epichrome-$(VERSION)-dist.xml build/resources/background.png build/resources/welcome.rtf build/resources/readme.rtf build/resources/license.rtf
	@rm -f '$@'
	productbuild --distribution build/epichrome-$(VERSION)-dist.xml \
		--version '$(VERSION)' \
		--package-path build \
		--resources build/resources \
		--sign '$(CODESIGN_IDENTITY)' \
		'$@'

build/epichrome-$(VERSION)-main.pkg: release build/scripts/postinstall build/icons/folder$(BETA).icns
	@rm -f '$@'
	xattr -cr $(APP)
	rm -rf build/package/Applications
	mkdir -p 'build/package/Applications/$(INSTALL_FOLDER)/Payload.noindex'
	../modules/fileicon/bin/fileicon set \
		'build/package/Applications/$(INSTALL_FOLDER)' \
		build/icons/folder$(BETA).icns
	touch 'build/package/Applications/$(INSTALL_FOLDER)/Payload.noindex/.preserve'
	mv $(APP) 'build/package/Applications/$(INSTALL_FOLDER)/$(EPICHROME_DISPNAME).app'
	mv $(SCAN_APP) 'build/package/Applications/$(INSTALL_FOLDER)/$(SCAN_DISPNAME).app'
	if ! ( pkgbuild --analyze --root build/package $(@:.pkg=).plist --version '$(VERSION)' && \
	plutil -replace BundleIsRelocatable -bool NO $(@:.pkg=).plist && \
	pkgbuild --root build/package \
		--identifier org.epichrome.Epichrome \
		--version '$(VERSION)' \
		--scripts build/scripts \
		--component-plist $(@:.pkg=).plist '$@' && \
	rm -f '$(@:.pkg=).plist' ) ; then \
		mv 'build/package/Applications/$(INSTALL_FOLDER)/$(EPICHROME_DISPNAME).app' $(APP) ; \
		mv 'build/package/Applications/$(INSTALL_FOLDER)/$(SCAN_DISPNAME).app' $(SCAN_APP) ; \
	fi
	mv 'build/package/Applications/$(INSTALL_FOLDER)/$(EPICHROME_DISPNAME).app' $(APP)
	mv 'build/package/Applications/$(INSTALL_FOLDER)/$(SCAN_DISPNAME).app' $(SCAN_APP)
	rm -rf build/package/Applications
	@cd build ; rmdir -p package

build/resources/background.png: ../images/package/background$(BETA).png
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

build/resources/welcome.rtf: src/package/welcome$(BETA).rtf src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSION/$(VERSIONTEXT)/g' '$<' > '$@'

build/resources/license.rtf: src/package/license.rtf src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

build/resources/readme.rtf: src/package/readme.rtf src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSION/$(VERSIONTEXT)/g' '$<' > '$@'

build/scripts/postinstall: src/package/scripts/postinstall
	@mkdir -p '$(dir $@)'
	sed 's/INSTALLDIR/$(INSTALL_FOLDER)/g' '$<' > '$@'
	chmod 755 '$@'

build/epichrome-$(VERSION)-dist.xml: build/epichrome-$(VERSION)-main.pkg src/package/requirements.plist
	@rm -f '$@'
	productbuild --synthesize \
		--product src/package/requirements.plist \
		--version '$(VERSION)' \
		--package '$<' \
		'$@'
	sed -E -i '' 's/enable_anywhere="true"/enable_anywhere="false"/; '\
'		s/EPIMINOS/'$(MIN_OS)'/; '\
'		s/(<pkg-ref id="org.epichrome.Epichrome"\/>.*$$)/\1'\\$$'\n'\
'    <title>Epichrome $(VERSIONTEXT)<\/title>'\\$$'\n'\
'    <background file="background.png" mime-type="image\/png" alignment="bottomleft" scaling="proportional"\/>'\\$$'\n'\
'    <welcome file="welcome.rtf" mime-type="application\/rtf"\/>'\\$$'\n'\
'    <readme file="readme.rtf" mime-type="application\/rtf"\/>'\\$$'\n'\
'    <license file="license.rtf" mime-type="application\/rtf"\/>/' '$@'


# NOTARIZE PACKAGE

notarize:
	scripts/notarize.sh --prompt $(VERSION)

notarize-staple:
	scripts/notarize.sh --staple $(VERSION)


# CODESIGNING

%.app: src/package/entitlements.plist
	xattr -cr '$@'
	codesign -vv --force --options runtime --entitlements src/package/entitlements.plist \
		-s '$(CODESIGN_IDENTITY)' '$@'
	codesign --verify --deep --strict --verbose=2 '$@'
	spctl --assess --type execute --verbose=4 '$@'
	touch '$@'
	osascript $(APP_RNTM)/Contents/Resources/Scripts/apputil.js '{"action": "register", "path": "$@"}'

verify:
	codesign --verify --deep --strict --verbose=2 '$(APP)'
	spctl --assess --type execute --verbose=4 '$(APP)'


# *** MAIN APP ***

# MAIN APP DEPENDENCIES

$(APP):	$(APP_CT)/PkgInfo \
	$(APP_CT)/MacOS/droplet \
	$(APP_CT)/Resources/droplet.rsrc \
	$(APP_CT)/Resources/Scripts/main.scpt \
	\
	$(APP_CT)/Info.plist \
	\
	$(LOGIN_APP) \
	\
	$(APP_CT)/Resources/droplet.icns \
	$(APP_CT)/Resources/Icons/apptemplate_bg_white.png \
	$(APP_CT)/Resources/Icons/apptemplate_bg_gray.png \
	$(APP_CT)/Resources/Icons/apptemplate_bg_black.png \
	$(APP_CT)/Resources/Icons/apptemplate_shadow.png \
	$(APP_CT)/Resources/Icons/doctemplate_fg.png \
	$(APP_CT)/Resources/Icons/doctemplate_bg.png \
	$(APP_CT)/Resources/scan.icns \
	\
	$(APP_CT)/Resources/Scripts/epichrome.sh \
	$(APP_CT)/Resources/Scripts/legacy.sh \
	$(APP_CT)/Resources/Scripts/makeicon.sh \
	$(APP_CT)/Resources/Scripts/makeicon.php \
	$(APP_CT)/Resources/Scripts/update.sh \
	$(APP_CT)/Resources/Scripts/version.sh \
	\
	$(APP_CT)/Resources/NMH/$(NMH_ID).json \
	$(APP_CT)/Resources/NMH/epichromeruntimehost_$(VERSION) \
	\
	$(APP_RNTM)/Filter/Info.plist \
	$(APP_RNTM)/Filter/AppExec \
	$(APP_RNTM)/Filter/main.sh \
	$(APP_RNTM)/Filter/welcome.html \
	$(APP_RNTM)/Filter/Bookmarks \
	$(APP_RNTM)/Filter/Prefs/prefs_com_brave_Browser.json \
	$(APP_RNTM)/Filter/Prefs/prefs_com_google_Chrome.json \
	$(APP_RNTM)/Filter/Prefs/prefs_nourl_com_brave_Browser.json \
	$(APP_RNTM)/Filter/Prefs/prefs_nourl_com_google_Chrome.json \
	\
	$(APP_RNTM)/Exec/Epichrome \
	\
	$(APP_RNTM)/Contents/Resources/MainMenu.nib \
	$(APP_RNTM)/Contents/Resources/AppSettings.plist \
	$(APP_RNTM)/Contents/Resources/app.icns \
	$(APP_RNTM)/Contents/Resources/document.icns \
	\
	$(PROGRESS_APP) \
	\
	$(APP_RNTM)/Contents/Resources/Scripts/apputil.js \
	$(APP_RNTM)/Contents/Resources/Scripts/core.sh \
	$(APP_RNTM)/Contents/Resources/Scripts/filter.sh \
	$(APP_RNTM)/Contents/Resources/Scripts/json.js \
	$(APP_RNTM)/Contents/Resources/Scripts/launch.sh \
	$(APP_RNTM)/Contents/Resources/Scripts/reporterr.js \
	$(APP_RNTM)/Contents/Resources/Scripts/runprogress.sh \
	\
	$(APP_RNTM)/Contents/Resources/Welcome/welcome.css \
	$(APP_RNTM)/Contents/Resources/Welcome/welcome.js \
	$(APP_RNTM)/Contents/Resources/Welcome/vcmp.js \
	$(APP_RNTM)/Contents/Resources/Welcome/img/app_icon.png \
	$(APP_RNTM)/Contents/Resources/Welcome/img/bookmark.png \
	$(APP_RNTM)/Contents/Resources/Welcome/img/epichrome_icon.png \
	$(APP_RNTM)/Contents/Resources/Welcome/img/ext_generic_icon.png \
	$(APP_RNTM)/Contents/Resources/Welcome/img/passwords_button.png \
	$(APP_RNTM)/Contents/Resources/Welcome/img/scan_icon.png \
	\
	$(APP_RNTM)/Engine/Filter/Info.plist \
	$(APP_RNTM)/Engine/Payload \
	$(APP_RNTM)/Engine/Link/Frameworks


# MAIN APP CORE

$(APP_CT)/PkgInfo $(APP_CT)/MacOS/droplet \
$(APP_CT)/Resources/droplet.rsrc \
$(APP_CT)/Resources/Scripts/main.scpt: src/main.js src/libapp.js src/libreporterr.js src/vcmp.js src/version.sh main

main:
	@mkdir -p build
	@rm -rf build/main.app build/main
	sed -e 's/EPIVERSION/$(VERSION)/g; s/GITHUBUPDATEURL/$(GITHUB_UPDATE_URL)/g' \
		src/main.js > build/main.js
	echo >> build/main.js
	cat src/libapp.js >> build/main.js  # EVENTUALLY OPTIMIZE MAIN.JS?
	cat src/libreporterr.js >> build/main.js
	cat src/vcmp.js >> build/main.js
	osacompile -l JavaScript -x -o build/main.app build/main.js
	codesign --remove-signature build/main.app
	chmod 444 build/main.app/Contents/Resources/Scripts/main.scpt  # lock main.scpt so it doesn't get altered with each run
	@mv build/main.app build/main
	@rm -f build/main.js
	@cd build/main/Contents && rm -f Info.plist Resources/droplet.icns
	@mkdir -p $(APP_CT)/MacOS $(APP_CT)/Resources/Scripts
	mv -f build/main/Contents/Resources/Scripts/main.scpt $(APP_CT)/Resources/Scripts/main.scpt
	@touch $(APP_CT)/Resources/Scripts/main.scpt
	mv -f build/main/Contents/PkgInfo $(APP_CT)/PkgInfo
	mv -f build/main/Contents/MacOS/droplet $(APP_CT)/MacOS/droplet
	mv -f build/main/Contents/Resources/droplet.rsrc $(APP_CT)/Resources/droplet.rsrc
	@touch $(APP_CT)/PkgInfo $(APP_CT)/MacOS/droplet $(APP_CT)/Resources/droplet.rsrc
	rmdir build/main/Contents/MacOS
	if [[ -d build/main/Contents/_CodeSignature ]] ; then rmdir build/main/Contents/_CodeSignature ; fi
	@cd build && if ! rmdir -p main/Contents/Resources/Scripts ; then \
		echo "*** Unexpected files found in main app (check build/main)." 1>&2 ; false ; fi
	@touch $(APP)


# MAIN APP BUNDLE ELEMENTS

$(APP_CT)/Info.plist: src/Info.plist src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIDISPNAME/$(EPICHROME_DISPNAME)/g; s/EPISHORTNAME/$(EPICHROME_SHORTNAME)/g; s/EPIVERSIONCODE/$(VERSIONCODE)/g; s/EPIVERSION/$(VERSION)/g; s/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

$(APP_CT)/Resources/droplet.icns: build/icons/epichrome$(BETA).icns
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_CT)/Resources/Icons/%.png: build/icons/%.png
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_CT)/Resources/scan.icns: build/icons/scan_app$(BETA).icns src/version.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_CT)/Resources/Scripts/version.sh: src/version.sh
	@mkdir -p '$(dir $@)'
	sed -E 's/^epiVersion=.*$$/epiVersion='\''$(VERSION)'\''/' '$<' > '$@'

$(APP_CT)/Resources/Scripts/update.sh: src/update.sh src/version.sh
	@mkdir -p '$(dir $@)'
	sed -e 's/EPIVERSION/$(VERSION)/g' '$<' > '$@'

$(APP_CT)/Resources/Scripts/%.sh: src/%.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_CT)/Resources/Scripts/%.php: src/%.php
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_CT)/Resources/NMH/epichromeruntimehost_$(VERSION): src/epichromeruntimehost.py src/version.sh
	@mkdir -p '$(dir $@)'
	sed -e 's/EPIVERSION/$(VERSION)/g' '$<' > '$@'
	chmod 755 '$@'


# PROGRESS SUB-APP

$(PROGRESS_APP): $(PROGRESS_CT)/MacOS/EpichromeProgress \
		$(PROGRESS_CT)/Resources/MainMenu.nib \
		$(PROGRESS_CT)/Resources/AppSettings.plist \
		\
		$(PROGRESS_CT)/Info.plist \
		$(PROGRESS_CT)/Resources/script \
		$(PROGRESS_CT)/Resources/app.icns \
		\
		$(PROGRESS_CT)/Resources/Scripts/progress.sh \
		$(PROGRESS_CT)/Resources/Scripts/mode_icon.sh \
		$(PROGRESS_CT)/Resources/Scripts/mode_extcache.sh \
		$(PROGRESS_CT)/Resources/Scripts/mode_payload.sh \
		$(PROGRESS_CT)/Resources/Scripts/mode_update.sh

$(PROGRESS_CT)/MacOS/EpichromeProgress \
	$(PROGRESS_CT)/Resources/MainMenu.nib \
	$(PROGRESS_CT)/Resources/AppSettings.plist: progress-core
	
progress-core: build/platypus
	@rm -rf $(PROGRESS_APP)
	@touch build/fake.icns build/fake.sh
	scripts/platypus.sh --name 'EpichromeProgress' \
		--interface-type 'Progress Bar' \
		--app-icon build/fake.icns \
		--interpreter /bin/bash \
		--app-version $(VERSION) \
		--author 'David Marmor' \
		--bundle-identifier org.epichrome.Progress \
		--background \
		--quit-after-execution \
		--optimize-nib \
		build/fake.sh $(PROGRESS_APP)
	@rm build/fake.icns build/fake.sh
	@rm $(PROGRESS_CT)/Info.plist $(PROGRESS_CT)/Resources/*.icns $(PROGRESS_CT)/Resources/script

$(PROGRESS_CT)/Info.plist: src/progress/Info.plist src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSIONCODE/$(VERSIONCODE)/g; s/EPIVERSION/$(VERSION)/g; s/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

$(PROGRESS_CT)/Resources/script: src/progress/ProgressExec src/version.sh
	@mkdir -p $(dir $@)
	sed -e 's/EPIVERSION/$(VERSION)/g' $< > $@
	chmod 755 $@

$(PROGRESS_CT)/Resources/app.icns: build/icons/app$(BETA).icns src/version.sh
	@mkdir -p $(dir $@)
	cp $< $@

$(PROGRESS_CT)/Resources/Scripts/%.sh: src/progress/%.sh
	@mkdir -p $(dir $@)
	cp $< $@


# *** RUNTIME CORE ***

# RUNTIME CORE

$(APP_RNTM)/Exec/Epichrome \
$(APP_RNTM)/Contents/Resources/MainMenu.nib \
$(APP_RNTM)/Contents/Resources/AppSettings.plist: runtime

runtime: build/platypus
	@rm -rf build/runtime.app build/runtime
	@touch build/fake.icns build/fake.sh
	scripts/platypus.sh --name Epichrome \
		 --interface-type None \
		 --app-icon build/fake.icns \
		 --document-icon build/fake.icns \
		 --interpreter /bin/bash \
		 --app-version $(VERSION) \
		 --author 'David Marmor' \
		 --bundle-identifier org.epichrome.APPBUNDLEID \
		 --droppable \
		 --background \
		 --quit-after-execution \
		 --uniform-type-identifiers 'com.compuserve.gif|public.html|public.jpeg|com.netscape.javascript-source|com.microsoft.word.mhtml|org.videolan.ogg-audio|org.videolan.ogg-audio|org.xiph.ogg-video|com.adobe.pdf|public.png|public.svg-image|public.plain-text|org.videolan.webm|public.webp|public.xhtml' \
		 --uri-schemes 'http|https|ftp|file' \
		 --optimize-nib \
		 build/fake.sh build/runtime.app
	mv build/runtime.app/Contents build/runtime
	rmdir build/runtime.app
	@rm build/fake.icns build/fake.sh
	@cd build/runtime && rm -f Info.plist Resources/*.icns Resources/script
	@mkdir -p $(APP_RNTM)/Contents/Resources
	mv -f build/runtime/Resources/MainMenu.nib $(APP_RNTM)/Contents/Resources/MainMenu.nib
	mv -f build/runtime/Resources/AppSettings.plist $(APP_RNTM)/Contents/Resources/AppSettings.plist
	@mkdir -p $(APP_RNTM)/Exec
	mv -f 'build/runtime/MacOS/Epichrome' $(APP_RNTM)/Exec
	xattr -c $(APP_RNTM)/Exec/Epichrome
	codesign -vv -s '$(CODESIGN_IDENTITY)' \
		--identifier 'org.epichrome.launcher' \
		--option runtime \
		--entitlements 'src/package/entitlements.plist' \
		$(APP_RNTM)/Exec/Epichrome
	@rmdir build/runtime/MacOS
	@cd build && if ! rmdir -p runtime/Resources ; then \
		echo '*** Unexpected files found in Platypus runtime app (check build/runtime).' 1>&2 ; false ; fi


# RUNTIME FILTER ELEMENTS

$(APP_RNTM)/Filter/Info.plist: src/Info.plist.runtime src/version.sh
	@mkdir -p '$(dir $@)'
	sed -e 's/EPIVERSIONCODE/$(VERSIONCODE)/g; s/EPIVERSION/$(VERSION)/g; s/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

$(APP_RNTM)/Filter/AppExec: src/AppExec
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Filter/main.sh: src/main.sh src/version.sh
	@mkdir -p '$(dir $@)'
	sed -e 's/EPIVERSION/$(VERSION)/g' '$<' > '$@'


# RUNTIME ICONS

$(APP_RNTM)/Contents/Resources/%.icns: build/icons/%$(BETA).icns src/version.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'


# RUNTIME SCRIPTS

$(APP_RNTM)/Contents/Resources/Scripts/core.sh: src/core.sh src/version.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSION/$(VERSION)/g; s/EPIDEBUG/$(DEBUG_SH)/g; s/EPILOGPRESERVE/$(LOGPRESERVE_SH)/g; s/EPIBACKUPPRESERVE/$(BACKUPPRESERVE_SH)/g' '$<' > '$@'

$(APP_RNTM)/Contents/Resources/Scripts/launch.sh: src/launch.sh
	@mkdir -p '$(dir $@)'
	sed 's/EPIEXTIDRELEASE/$(EXTN_ID_RELEASE)/g; s/EPIEXTIDBETA/$(EXTN_ID_BETA)/g; s/GITHUBUPDATEURL/$(GITHUB_UPDATE_URL)/g' '$<' > '$@'

$(APP_RNTM)/Contents/Resources/Scripts/apputil.js: src/apputil.js src/libapp.js
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSION/$(VERSION)/g' '$<' > '$@'
	echo >> '$@'
	cat 'src/libapp.js' >> '$@'

$(APP_RNTM)/Contents/Resources/Scripts/reporterr.js: src/reporterr.js src/libreporterr.js
	@mkdir -p '$(dir $@)'
	sed 's/EPIVERSION/$(VERSION)/g' '$<' > '$@'
	echo >> '$@'
	cat 'src/libreporterr.js' >> '$@'

$(APP_RNTM)/Contents/Resources/Scripts/%.js: src/%.js
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Scripts/%.sh: src/%.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'


# PROFILE FILES

$(APP_RNTM)/Filter/Bookmarks: src/profile/bookmarks.json
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Filter/Prefs/prefs_nourl_%.json: src/profile/prefs_%.json
	@mkdir -p '$(dir $@)'
	sed 's/"restore_on_startup": 5/"restore_on_startup": 1/' '$<' > '$@'

$(APP_RNTM)/Filter/Prefs/%.json: src/profile/%.json
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'


# CHROME EXTENSION

$(APP_CT)/Resources/NMH/$(NMH_ID).json: src/$(NMH_ID).json src/version.sh
	@mkdir -p '$(dir $@)'
	sed -E -e 's/EPIVERSION/$(VERSION)/g; s/EPIRUNTIMEIDS/"chrome-extension:\/\/$(EXTN_ID_RELEASE)\/",\'$$'\n''        "chrome-extension:\/\/$(EXTN_ID_BETA)\/"/' $< > $@


# WELCOME PAGE

$(APP_RNTM)/Filter/welcome.html: src/welcome/welcome.html src/version.sh
	@mkdir -p '$(dir $@)'
	sed -e 's/EPIVERSION/$(VERSION)/g; s/EPIMAJORVERSION/$(VERSIONMAJOR)/g; s/EPIEXTIDRELEASE/$(EXTN_ID_RELEASE)/g; s/EPIEXTIDBETA/$(EXTN_ID_BETA)/g' '$<' > '$@'

$(APP_RNTM)/Contents/Resources/Welcome/welcome.%: src/welcome/welcome.%
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Welcome/vcmp.js: src/vcmp.js
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Welcome/img/app_icon.png: build/img/app_icon$(BETA).png src/version.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Welcome/img/epichrome_icon.png: build/img/epichrome_icon.png
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Welcome/img/scan_icon.png: build/img/scan_icon$(BETA).png src/version.sh
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

$(APP_RNTM)/Contents/Resources/Welcome/img/%: src/welcome/img/%
	@mkdir -p '$(dir $@)'
	cp '$<' '$@'

build/img/app_icon$(BETA).png: build/icons/app$(BETA).png
	@mkdir -p '$(dir $@)'
	sips -z 128 128 $< --out $@

build/img/epichrome_icon.png: build/icons/app_core.png
	@mkdir -p '$(dir $@)'
	sips -z 128 128 $< --out $@

build/img/scan_icon$(BETA).png: build/icons/scan_app$(BETA).png
	@mkdir -p '$(dir $@)'
	sips -z 128 128 $< --out $@


# *** ENGINE ***

build/engine/%:
	@rm -rf build/engine/$*
	@mkdir -p '$(dir $@)'
	tar xzvf '$<' --cd build/engine


# CODESIGNED CHROMIUM

build/engine/Chromium: $(CHROMIUM)

CHROMIUM_FRAMEWORK:=build/chromium/Contents/Frameworks/Chromium Framework.framework
# find Chromium.app -exec bash -c 'codesign --verify --deep --strict "{}" 2> /dev/null && codesign --verify --deep --strict --verbose=2 "{}"' ';'
$(CHROMIUM): $(CHROMIUM:.tgz=.zip)
	@mkdir -p build/chromium
	tar xzvf '$<' --cd build/chromium --strip-components 1
	codesign --remove-signature -vv build/chromium
	rm -rf build/chromium/Contents/_CodeSignature
	rm -f build/chromium/Contents/CodeResources
# codesign --remove-signature -vv \
# 	'$(CHROMIUM_FRAMEWORK)' \
# 	'$(CHROMIUM_FRAMEWORK)/Versions/Current/XPCServices/AlertNotificationService.xpc' \
# 	'$(CHROMIUM_FRAMEWORK)/Versions/Current/Helpers/'*
# rmdir '$(CHROMIUM_FRAMEWORK)/Versions/Current/_CodeSignature' \
# 	'$(CHROMIUM_FRAMEWORK)/Versions/Current/XPCServices/AlertNotificationService.xpc/Contents/_CodeSignature' \
# 	'$(CHROMIUM_FRAMEWORK)/Versions/Current/Helpers/'*.app/Contents/_CodeSignature
	scripts/signmatch.sh '/Applications/Google Chrome.app' build/chromium \
		'$(CHROMIUM_FRAMEWORK)/Versions/Current/Libraries/'*.dylib \
		'$(CHROMIUM_FRAMEWORK)/Versions/Current/Helpers/'* \
		'$(CHROMIUM_FRAMEWORK)/Versions/Current/XPCServices/AlertNotificationService.xpc' \
		'$(CHROMIUM_FRAMEWORK)'
#		'build/chromium'
	@rm -rf build/engine/Chromium
	@mkdir -p build/engine
	mv build/chromium/Contents build/engine/Chromium
	rmdir build/chromium
	tar czvf '$@' --cd build/engine Chromium
	@touch build/engine/Chromium



# BRAVE MINUS SPARKLE

build/engine/Brave: $(BRAVE)

BRAVE_FRAMEWORK:=build/engine_tmp/brave/Contents/Frameworks/Brave Browser Framework.framework
$(BRAVE): build/engine_tmp/brave
	@rm -rf build/engine/Brave
	@mkdir -p build/engine
	mv build/engine_tmp/brave/Contents build/engine/Brave
	rmdir build/engine_tmp/brave
	tar czvf '$@' --cd build/engine Brave
	@touch build/engine/Brave
	rm -rf build/engine_tmp

build/engine_tmp/brave: build/engine_tmp/$(BRAVE_SRC) build/engine_tmp/brave_recodesign.sh
	@rm -rf '$@'
	mv -f '$<' '$@'
	codesign --remove-signature build/engine_tmp/brave
	rmdir build/engine_tmp/brave/Contents/_CodeSignature
	rm build/engine_tmp/brave/Contents/CodeResources
	mkdir build/engine_tmp/brave/Contents/Exec
	mv -f 'build/engine_tmp/brave/Contents/MacOS/Brave Browser' build/engine_tmp/brave/Contents/Exec
	rmdir build/engine_tmp/brave/Contents/MacOS
	xattr -c 'build/engine_tmp/brave/Contents/Exec/Brave Browser'
	/bin/sh 'build/engine_tmp/brave_recodesign.sh'
	codesign --display -vv --entitlements - 'build/engine_tmp/brave/Contents/Exec/Brave Browser' 1>&2
	rm -f 'build/engine_tmp/brave_recodesign.sh' 'build/engine_tmp/brave_entitlements.plist'
	@if [[ ! -d '$(BRAVE_FRAMEWORK)/Versions/Current/Frameworks/Sparkle.framework' ]] ; then \
		echo '*** Unable to find Sparkle.framework' 1>&2 ; false ; fi
	rm -rf '$(BRAVE_FRAMEWORK)/Versions/Current/Frameworks/Sparkle.framework'
	xattr -cr build/engine_tmp/brave
	shopt -s nullglob && scripts/signmatch.sh '' \
		'$(BRAVE_FRAMEWORK)/Versions/Current/Helpers/'* \
		'$(BRAVE_FRAMEWORK)/Versions/Current/Libraries/'*.dylib \
		'$(BRAVE_FRAMEWORK)/Versions/Current/XPCServices/'* \
		'$(BRAVE_FRAMEWORK)'

#flags="$${opts#*CodeDirectory}" && flags="$${flags%%Signature*}"
build/engine_tmp/brave_recodesign.sh:
	@mkdir -p build/engine_tmp
	printf "codesign -s '$(CODESIGN_IDENTITY)' -vv --identifier org.epichrome.engine.brave" > '$@'
	opts="$$(codesign --display -v --entitlements - --xml 'build/engine_tmp/$(BRAVE_SRC)/Contents/MacOS/Brave Browser' 2>&1)" && \
	ents="<?xml$${opts##*<?xml}" && \
	entfile='build/engine_tmp/brave_entitlements.plist' && \
	touch "$$entfile" && \
	if [[ "$$opts" =~ flags=0x[0-9a-z]+\(([^ ]+)\) ]] ; then \
		if [[ "$${BASH_REMATCH[1]}" != 'none' ]] ; then \
			printf " --options \"$${BASH_REMATCH[1]}\"" >> '$@' ; \
			if [[ "$$ents" != "$$opts" ]] ; then \
				echo "$$ents" > "$$entfile" ; \
				printf " --entitlements '$$entfile'" >> '$@' ; \
				pbcmds=() ; \
				if /usr/libexec/PlistBuddy -c 'Print :com.apple.application-identifier' "$$entfile" > /dev/null ; then \
					pbcmds+=( -c 'Set :com.apple.application-identifier $(CODESIGN_IDENTITY).org.epichrome.engine.brave' ) ; \
				fi ; \
				for badkey in keychain-access-groups com.apple.developer.associated-domains.applinks.read-write com.apple.developer.networking.vpn.api ; do \
					if /usr/libexec/PlistBuddy -c "Print :$$badkey" "$$entfile" > /dev/null ; then \
						pbcmds+=( -c "Delete :$$badkey" ) ; \
						fi ; \
				done ; \
				if [[ "$${pbcmds[*]}" ]] ; then \
					/usr/libexec/PlistBuddy "$${pbcmds[@]}" "$$entfile" ; \
				fi ; \
			fi ; \
		fi ; \
	fi
	printf " 'build/engine_tmp/brave/Contents/Exec/Brave Browser'" >> '$@'

build/engine_tmp/brave_dmg: $(BRAVE:.tgz=.dmg)
	@rm -rf build/engine_tmp
	@mkdir -p build/engine_tmp
	hdiutil attach -nobrowse -mountpoint build/dmg '$<' && \
	cp -PRv 'build/dmg/Brave Browser.app' build/engine_tmp/brave_dmg ; \
	hdiutil detach build/dmg
	touch build/engine_tmp/brave_dmg

build/engine_tmp/brave_pkg: $(BRAVE:.tgz=.pkg)
	@rm -rf build/engine_tmp
	@mkdir -p build/engine_tmp
	pkgutil --expand-full $< build/engine_tmp/tmp
	mv 'build/engine_tmp/tmp/Payload/Brave Browser.app' build/engine_tmp/brave_pkg
	rm -rf build/engine_tmp/tmp
	touch build/engine_tmp/brave_pkg


# ENGINE FILTER ELEMENTS

$(APP_RNTM)/Engine/Filter/Info.plist \
$(APP_RNTM)/Engine/Exec/Brave Browser \
$(APP_RNTM)/Engine/Payload \
$(APP_RNTM)/Engine/Link/Frameworks: \
		$(BRAVE) src/version.sh engine

engine: build/engine/Brave
	@if [[ "$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' build/engine/Brave/Info.plist)" != 'app.icns' ]] ; then \
		echo '*** Internal engine app icon name has changed.' 1>&2 ; false ; fi
	/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString $(VERSION)' \
				-c 'Delete :CFBundleDocumentTypes' \
				-c 'Delete :CFBundleURLTypes' \
				build/engine/Brave/Info.plist
	@mkdir -p $(APP_RNTM)/Engine/Filter
	mv -f build/engine/Brave/Info.plist $(APP_RNTM)/Engine/Filter/Info.plist
	/usr/libexec/PlistBuddy -c 'Add :LSArchitecturePriority array' -c 'Add :LSArchitecturePriority: string arm64' -c 'Add :LSArchitecturePriority: string x86_64' $(APP_RNTM)/Engine/Filter/Info.plist
	rm -rf $(APP_RNTM)/Engine/Exec $(APP_RNTM)/Engine/Link $(APP_RNTM)/Engine/Payload
	mv -f build/engine/Brave/Exec $(APP_RNTM)/Engine
	mkdir -p $(APP_RNTM)/Engine/Link
	mv build/engine/Brave/Frameworks $(APP_RNTM)/Engine/Link/Frameworks
	@touch $(APP_RNTM)/Engine/Link/Frameworks
	rm -f build/engine/Brave/Resources/*.icns
	@mkdir -p $(APP_RNTM)/Engine/Exec
#	openssl AES-128-CBC -k data -in 'build/engine/Brave/MacOS/Brave Browser' -out '$(APP_RNTM)/Engine/exec.dat'
#	rm 'build/engine/Brave/MacOS/Brave Browser'
#	rmdir build/engine/Brave/MacOS
	mv build/engine/Brave $(APP_RNTM)/Engine/Payload
	@touch $(APP_RNTM)/Engine/Payload


# *** SCAN/LOGIN APPS ***

# SCAN APP DEPENDENCIES

$(SCAN_APP): $(SCAN_CT)/MacOS/EpichromeScan \
	$(SCAN_CT)/Resources/MainMenu.nib \
	$(SCAN_CT)/Resources/AppSettings.plist \
	\
	$(SCAN_CT)/Info.plist \
	$(SCAN_CT)/Resources/script \
	$(SCAN_CT)/Resources/app.icns \
	\
	$(SCAN_CT)/Resources/Scripts/core.sh \
	$(SCAN_CT)/Resources/Scripts/filter.sh \
	$(SCAN_CT)/Resources/Scripts/apputil.js \
	$(SCAN_CT)/Resources/Scripts/launch.sh \
	$(SCAN_CT)/Resources/Scripts/progress.sh


# LOGIN APP DEPENDENCIES

$(LOGIN_APP): $(LOGIN_CT)/MacOS/EpichromeLogin \
		\
		$(LOGIN_CT)/Info.plist \
		$(LOGIN_CT)/Resources/app.icns \
		\
		$(LOGIN_CT)/Resources/Scripts/core.sh \
		$(LOGIN_CT)/Resources/Scripts/filter.sh \
		$(LOGIN_CT)/Resources/Scripts/apputil.js \
		$(LOGIN_CT)/Resources/Scripts/launch.sh


# SCAN APP ELEMENTS

$(SCAN_CT)/MacOS/EpichromeScan \
	$(SCAN_CT)/Resources/MainMenu.nib \
	$(SCAN_CT)/Resources/AppSettings.plist: scan-core

scan-core: build/platypus
	@rm -rf $(SCAN_APP)
	@touch build/fake.icns build/fake.sh
	scripts/platypus.sh --name 'EpichromeScan' \
		--interface-type 'Progress Bar' \
		--app-icon build/fake.icns \
		--interpreter /bin/bash \
		--app-version $(VERSION) \
		--author 'David Marmor' \
		--bundle-identifier org.epichrome.Scan \
		--optimize-nib \
		build/fake.sh $(SCAN_APP)
	@rm build/fake.icns build/fake.sh
	@rm $(SCAN_CT)/Info.plist $(SCAN_CT)/Resources/*.icns $(SCAN_CT)/Resources/script


# SCAN/LOGIN APP ELEMENTS

$(SCAN_CT)/Info.plist: src/scan/Info.plist.scan src/version.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	sed 's/SCANDISPNAME/$(SCAN_DISPNAME)/g; s/SCANSHORTNAME/$(SCAN_SHORTNAME)/g; s/EPIVERSIONCODE/$(VERSIONCODE)/g; s/EPIVERSION/$(VERSION)/g; s/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

$(LOGIN_CT)/Info.plist: src/scan/Info.plist.login src/version.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	sed 's/LOGINDISPNAME/$(LOGIN_DISPNAME)/g; s/LOGINSHORTNAME/$(LOGIN_SHORTNAME)/g; s/EPIVERSIONCODE/$(VERSIONCODE)/g; s/EPIVERSION/$(VERSION)/g; s/THISYEAR/$(THISYEAR)/g' '$<' > '$@'

$(LOGIN_CT)/MacOS/EpichromeLogin: SCAN_MODE:=login

$(SCAN_CT)/Resources/script: SCAN_MODE:=scan
	
$(SCAN_CT)/Resources/script $(LOGIN_CT)/MacOS/EpichromeLogin: src/scan/ScanExec
	@dir='$@' ; mkdir -p "$${dir%/*}"
	sed -e 's/EPISCANMODE/$(SCAN_MODE)/g' '$<' > '$@'
	chmod 755 '$@'

$(SCAN_CT)/Resources/app.icns: build/icons/scan_app$(BETA).icns src/version.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp '$<' '$@'

$(LOGIN_CT)/Resources/app.icns: build/icons/login_app$(BETA).icns src/version.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp '$<' '$@'

$(SCAN_CT)/Resources/Scripts/progress.sh: src/progress/progress.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp '$<' '$@'

$(SCAN_CT)/Resources/Scripts/%.sh: $(APP_RNTM)/Contents/Resources/Scripts/%.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp '$<' '$@'

$(LOGIN_CT)/Resources/Scripts/%.sh: $(APP_RNTM)/Contents/Resources/Scripts/%.sh
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp '$<' '$@'

$(SCAN_CT)/Resources/Scripts/apputil.js $(LOGIN_CT)/Resources/Scripts/apputil.js: $(APP_RNTM)/Contents/Resources/Scripts/apputil.js
	@dir='$@' ; mkdir -p "$${dir%/*}"
	cp -a '$<' '$@'


# PLATYPUS

build/platypus:
	rm -rf '$@'
	xcodebuild -parallelizeTargets -project ../modules/platypus/Platypus.xcodeproj -target Platypus -configuration 'Deployment' -arch x86_64 -arch arm64 CONFIGURATION_BUILD_DIR=../../app/build/platypus DEVELOPMENT_TEAM='$(CODESIGN_IDENTITY)' clean build
	rm -f $@/platypus_clt
	gzcat $@/Platypus.app/Contents/Resources/platypus_clt.gz > $@/platypus
	chmod 755 $@/platypus
	mkdir $@/library
	cp $@/ScriptExec.app/Contents/MacOS/ScriptExec $@/library
	rm -rf $@/Platypus.app $@/ScriptExec.app
	mkdir $@/library/MainMenu.nib
	gunzip $@/designable.nib.gz $@/keyedobjects.nib.gz
	chmod 755 $@/designable.nib $@/keyedobjects.nib
	mv $@/designable.nib $@/keyedobjects.nib $@/library/MainMenu.nib
