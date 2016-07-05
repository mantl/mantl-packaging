#!/bin/bash
# This script has to be executed from the root mantl-packaging directory.
set -e

OUTPUT=${1:-out}

if [ -f ./.bintray ]; then
    source .bintray
fi

if curl -s -I "https://api.bintray.com/repos/$BINTRAY_PROJECT" | grep -q 404; then
    echo "package repository not found, creating repository"
    curl -u$BINTRAY_USER:$BINTRAY_API_KEY -X POST -I "https://api.bintray.com/repos/$BINTRAY_PROJECT"
fi

for PKG in $(ls $OUTPUT); do
    if curl -s -I "https://api.bintray.com/packages/$BINTRAY_PROJECT/$PKG" | grep -q 404; then
        echo "package $PKG not found, creating package "
        PKG_NAME=$(echo $PKG | sed -E "s|^(([a-zA-Z\-]+)-([0-9\.\-]+)\..*)$|\2|")
        PKG_VCS_URL=https://github.com/asteris-llc/mantl-packaging/tree/master/$(grep "$PKG_NAME" scripts/paths | awk '{print $2}')
        PKG_METADATA='{"name": "'$PKG_NAME'", "licenses": ["Apache-2.0"], "vcs_url": "'$PKG_VCS_URL'"}'
        echo $PKG_METADATA | curl  -u$BINTRAY_USER:$BINTRAY_API_KEY -d @- https://api.bintray.com/packages/$BINTRAY_PROJECT --header "Content-Type:application/json"
    fi

    DOWNLOAD_URL="https://bintray.com/artifact/download/$BINTRAY_PROJECT/$PKG"

    if curl -s -I $DOWNLOAD_URL | grep -q 302; then
        echo "$PKG:	found, not uploading"
        continue
    fi

    echo "$PKG:\tuploading"
    URL=$(echo $PKG | sed -E "s|^(([a-zA-Z\-]+)-([0-9\.\-]+)\..*)$|https://api.bintray.com/content/$BINTRAY_PROJECT/\2/\3/\1|")
    RESP=$(curl -T $OUTPUT/$PKG -u$BINTRAY_USER:$BINTRAY_API_KEY $URL)
    if [[ "$RESP" == '{"message":"success"}' ]]; then
        echo "$PKG:	succesfully uploaded"

        echo "$PKG:\tpublishing"
        PUBLISH_URL=$(echo $PKG | sed -E "s|^([a-zA-Z\-]+)-([0-9\.\-]+)\..*$|https://api.bintray.com/content/$BINTRAY_PROJECT/\1/\2/publish|")
        curl -u$BINTRAY_USER:$BINTRAY_API_KEY -X POST $PUBLISH_URL
    else
        echo "$PKG:	error uploading"
        echo $RESP
        exit 1
    fi
done
