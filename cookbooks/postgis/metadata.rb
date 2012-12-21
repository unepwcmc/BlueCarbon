maintainer        "Stuart King"
maintainer_email  "stuartrexking@gmail.com"
license           "Stuart King"
description       "Installs and configures postgis"
version           "1.0.0"

recipe "postgis", "Install postgis"

%w{ debian ubuntu centos redhat fedora }.each do |os|
  supports os
end
