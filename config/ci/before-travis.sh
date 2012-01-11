# Start xvfb in preparation for cucumber
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://extjs.cachefly.net/ext-4.0.2a-gpl.zip
unzip -q -d test/basepack_test_app/public/ -n ext-4.0.2a-gpl.zip
mv test/basepack_test_app/public/ext-4.0.2a test/basepack_test_app/public/extjs

# cp db configuration
cp test/basepack_test_app/config/database.yml.travis  test/basepack_test_app/config/database.yml

# clone netzke-core and netzke-persistence gems into test project
mkdir -p test/basepack_test_app/vendor/gems
cd test/basepack_test_app/vendor/gems
git clone git://github.com/skozlov/netzke-core.git
cd netzke-core
git checkout tags/v0.7.4
cd ..
git clone git://github.com/skozlov/netzke-persistence.git
cd netzke-persistence
git checkout tags/v0.1.0
cd ../../..
bundle install
cd ../..
