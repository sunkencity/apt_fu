
#change these to fit
DEB_VERSION    = "0.1"
PACKAGE_NAME   = "railsapp"
INSTALL_PATH   = "var/www/railsapp"
MAINTAINER     = "Your-Name-Here <someone@example.com>"
DESCRIPTION    = "A rails app"
DEPLOY_USER    = "root"
DEPLOY_SERVER  = "aws.prodserver.example.com"

#if you are running linux-vserver virtualization on the production machine
DEPLOY_VSERVER ="guest"

#leave these guys alone
TEMP_PATH    = "#{RAILS_ROOT}/tmp/deb-tmp"
TARGET_PATH  = "#{TEMP_PATH}/#{INSTALL_PATH}"
DEB          = "#{PACKAGE_NAME}-#{DEB_VERSION}.deb"
DEB_PATH     = "#{RAILS_ROOT}/tmp"

namespace :deb do
  desc "Create a deb file from the rails package"
  task :create do

    puts `cd #{RAILS_ROOT}
rm -rf #{TEMP_PATH}
mkdir -p #{TARGET_PATH}
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1
cp -R app db/migrate lib public vendor config Rakefile #{TARGET_PATH}
mkdir #{TARGET_PATH}/tmp
touch #{TARGET_PATH}/tmp/restart.txt #will restart passenger
mkdir #{TARGET_PATH}/log
cd #{TEMP_PATH}
tar czf data.tar.gz #{INSTALL_PATH}
# write the control file
cat > control <<END
Package: #{PACKAGE_NAME}
Version: #{DEB_VERSION}
Section: www
Priority: optional
Architecture: all
Installed-Size: \`du -ks #{TARGET_PATH}|cut -f 1\`
Maintainer: #{MAINTAINER}
Description: #{DESCRIPTION}
END

tar czf control.tar.gz control
echo 2.0 > debian-binary
ar -r #{DEB} debian-binary control.tar.gz data.tar.gz
mv #{DEB} #{DEB_PATH}/
rm -rf #{TEMP_PATH}
`
  end

  #these are very simple deployment tasks that probably need more work...
  desc "Deploy"
  task :deploy do
    puts `scp #{DEB_PATH}/#{DEB} #{DEPLOY_USER}@:#{DEPLOY_SERVER}/tmp`
    puts `ssh #{DEPLOY_USER}@#{DEPLOY_SERVER} dpkg -i /tmp/#{DEB}`
  end

  desc "Deploy to vserver"
  task :vdeploy do
    puts `scp #{DEB_PATH}/#{DEB} #{DEPLOY_USER}@#{DEPLOY_SERVER}:/vservers/#{DEPLOY_VSERVER}/root/`
    puts `ssh #{DEPLOY_USER}@#{DEPLOY_SERVER} vserver #{DEPLOY_VSERVER} exec dpkg -i /root/#{DEB}`
  end

end


