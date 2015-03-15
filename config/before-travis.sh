# Start xvfb in preparation for selenium-webdriver
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://cdn.sencha.com/ext/gpl/ext-5.1.0-gpl.zip
unzip -q ext-5.1.0-gpl.zip
mv ext-5.1.0.* spec/rails_app/public/extjs
