set -ex
tar -xzf mesos-{{.Version}}.tar.gz

## build mesos
cd mesos-{{.Version}}
mkdir build
pushd build
../configure --prefix=/usr --enable-optimize
make -j {{.CPUs}}
popd

## create an installation
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL
( cd build/ && make install DESTDIR="$INSTALL" )

pushd $INSTALL
mkdir -p var/log/mesos var/lib/mesos

# jars
mkdir -p usr/share/java
cp {{.BuildRoot}}/mesos-{{.Version}}/build/src/java/target/mesos-*.jar usr/share/java

# symlinks
mkdir -p usr/local/lib
# ensure symlinks are relative so they work as expected in the final env
( cd usr/local/lib && cp -s ../../lib/lib*so . )
