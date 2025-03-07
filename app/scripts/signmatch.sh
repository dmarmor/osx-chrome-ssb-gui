#!/bin/bash
#
#  signmatch.sh: re-codesign a Chromium-like engine, matching all options & entitlements
#
#  Copyright (C) 2022  David Marmor
#
#  https://github.com/dmarmor/epichrome
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


# info for matching signature to a different app
ref_app="$1" ; shift
if [[ "$ref_app" ]] ; then
    ref_name="${ref_app##*/}"
    ref_name="${ref_name%.[aA][pP][pP]}"
    
    prefix="$1" ; shift
    
    path_re='/([^/]*) Framework'
fi

tmpentitlementsfile=build/curentitlements.plist
dev_id="$(cat "private/codesign_identity.txt")"

for path in "$@" ; do

    if [[ "$ref_app" ]] ; then
	relpath="${path#$prefix}"
	relpath="${relpath#/}"
	
	if [[ "$relpath" ]] ; then
	    if [[ "$relpath" =~ $path_re ]] ; then
		ref_app_path="$ref_app/${relpath//${BASH_REMATCH[1]}/$ref_name}"
	    else
		ref_app_path="$ref_app/$relpath"
	    fi
	else
	    ref_app_path="$ref_app"
	fi
    else
	# no other ref app, so just look at the existing signature
	ref_app_path="$path"
    fi
    
    cmdline=( --verbose=2 --force -s "$dev_id" )

    entitlements=
    
    opts="$(codesign --display --verbose=1 "$ref_app_path" 2>&1)"
    if [[ "$?" != 0 ]] ; then
	if [[ "${opts%: No such file or directory}" != "$opts" ]] ; then
	    echo "'$ref_app_path' not found, signing with no options"
	    opts='flags=0x0(none)'
	else
	    echo "$opts" 1>&2
	    exit 1
	fi
    fi
    
    if [[ "$opts" =~ flags=0x[0-9a-z]+\(([^ ]+)\) ]] ; then
	
	opts="${BASH_REMATCH[1]}"
	
	if [[ "$opts" != 'none' ]] ; then
	    
	    cmdline+=( --options "$opts" )
	    
	    if [[ "$opts" =~ runtime ]] ; then
		
		disp="$(codesign --display --entitlements - --xml --verbose=0 "$ref_app_path" 2>&1)"
		if [[ "$?" != 0 ]] ; then
		    echo "$disp" 1>&2
		    exit 1
		fi
		
		entitlements="${disp#*<?xml}"
		if [[ "$entitlements" != "$disp" ]] ; then
		    echo "<?xml$entitlements" > "$tmpentitlementsfile" || exit 1
		    #/usr/libexec/PlistBuddy -c 'Delete :com.apple.application-identifier' -c 'Delete :keychain-access-groups' "$tmpentitlementsfile"
		    cmdline+=( --entitlements "$tmpentitlementsfile" )
		else
		    entitlements=
		fi
	    fi
	fi

	echo codesign "${cmdline[@]}" "$path"
	[[ "$entitlements" ]] && ( echo '--- entitlements ---' ; cat "$tmpentitlementsfile" ; echo '---' ; echo )
	codesign "${cmdline[@]}" "$path"
	result="$?"
	rm -f "$tmpentitlementsfile"
	[[ "$result" = 0 ]] || exit 1
    else
	echo "*** Can't parse code signature for '$ref_app_path'" 1>&2
	exit 1
    fi
done

exit 0
