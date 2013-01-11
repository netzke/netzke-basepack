# Start xvfb in preparation for cucumber
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://cdn.sencha.io/ext-4.1.1a-gpl.zip
unzip -q -d test/basepack_test_app/public/ -n ext-4.1.1a-gpl.zip
mv test/basepack_test_app/public/ext-4.1.1a test/basepack_test_app/public/extjs
