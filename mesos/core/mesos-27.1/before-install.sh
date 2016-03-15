# create some directories which conflict with other packages if specified as
# being managed by the package
for dir in /usr/share/java /usr/lib/python2.7/site-packages; do
    mkdir -p $dir || true
done
