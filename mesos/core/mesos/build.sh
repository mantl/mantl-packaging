set -ex
tar -xzf mesos-{{.Version}}.tar.gz

echo `pwd`

## Dependencies
sudo wget https://raw.githubusercontent.com/kazuho/picojson/v1.3.0/picojson.h -O /usr/local/include/picojson.h
sudo yum install -y protobuf-devel protobuf-java protobuf-python boost-devel 

## create an installation
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL 

# glog
wget https://github.com/google/glog/archive/v0.3.4.tar.gz
tar -xzvf v0.3.4.tar.gz
cd glog-0.3.4
./configure
make 
sudo make install 
make install DESTDIR="$INSTALL" 
cd ..

## build mesos
cd mesos-{{.Version}}
./bootstrap
mkdir build
pushd build
../configure --prefix=/usr --with-protobuf=/usr --with-boost=/usr --with-glog=${INSTALL}/usr/local/ --enable-optimize 
make -j {{.CPUs}} 
make install DESTDIR="$INSTALL" 
popd

pushd $INSTALL
mkdir -p var/log/mesos var/lib/mesos 

# jars
mkdir -p usr/share/java || echo "dirs for jars"
cp {{.BuildRoot}}/mesos-{{.Version}}/build/src/java/target/mesos-*.jar usr/share/java
popd


## Net-modules
git clone https://github.com/mesosphere/net-modules.git -b integration/0.26
cd net-modules/isolator

# Configure and build
pushd ${INSTALL}/usr/
ln -s lib lib64
popd

./bootstrap
mkdir build 
cd build
../configure --with-mesos=${INSTALL}/usr --with-protobuf=/usr 
make 
make install DESTDIR="$INSTALL" 

pushd ${INSTALL}/usr/
rm -f lib64
popd

pushd $INSTALL
# symlinks
mkdir -p usr/local/lib 
# ensure symlinks are relative so they work as expected in the final env
( cd usr/local/lib && cp -s ../../lib/lib*so . )

