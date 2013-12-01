# Start xvfb in preparation for cucumber
sh -e /etc/init.d/xvfb start

# fetch extjs
wget http://cdn.sencha.com/ext/gpl/ext-4.2.1-gpl.zip
unzip -q -d spec/rails_app/public/ -n ext-4.2.1-gpl.zip
mv spec/rails_app/public/ext-4.2.1 spec/rails_app/public/extjs
