#/bin/bash
set -e

OUTPUT=${1:-out}

for PKG in $(ls $OUTPUT); do
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
