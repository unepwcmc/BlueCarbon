#!/bin/bash

export LANG="en_US.utf8"

# PostgreSQL

command -v psql >/dev/null 2>&1 || {
  echo "$(date +"%T") Installing PostgreSQL..."
  echo "---------------------------------"
  sudo apt-get update
  sudo apt-get -y install python-software-properties
  sudo add-apt-repository ppa:pitti/postgresql
  sudo apt-get update
  sudo apt-get -y install vim postgresql-9.2 build-essential g++ make postgresql-server-dev-9.2 libxml2-dev

  # Permissions

  sudo su -c 'echo "local   all             postgres                                trust" >  /etc/postgresql/9.2/main/pg_hba.conf'
  sudo su -c 'echo "local   all             all                                     trust" >> /etc/postgresql/9.2/main/pg_hba.conf'
  sudo su -c 'echo "host    all             all             127.0.0.1/32            trust" >> /etc/postgresql/9.2/main/pg_hba.conf'
  sudo su -c 'echo "host    all             all             ::1/128                 trust" >> /etc/postgresql/9.2/main/pg_hba.conf'

  pg_createcluster 9.2 utf8_cluster
  sudo /etc/init.d/postgresql restart
}

# GEOS

command -v geos-config >/dev/null 2>&1 || {
  echo "$(date +"%T") Installing GEOS..."
  echo "---------------------------"
  wget -q http://download.osgeo.org/geos/geos-3.3.6.tar.bz2
  tar jxf geos-3.3.6.tar.bz2
  cd geos-3.3.6
  ./configure
  make
  sudo make install
}

# PROJ.4

command -v proj >/dev/null 2>&1 || {
  echo "$(date +"%T") Installing GEOS..."
  echo "---------------------------"
  cd $HOME
  wget -q http://download.osgeo.org/proj/proj-4.8.0.tar.gz
  tar xvfz proj-4.8.0.tar.gz
  cd proj-4.8.0
  ./configure
  make
  sudo make install
  sudo ldconfig
}

# GDAL

command -v gdal-config >/dev/null 2>&1 || {
  echo "$(date +"%T") Installing GDAL..."
  echo "---------------------------"
  cd $HOME
  wget -q http://download.osgeo.org/gdal/gdal-1.9.2.tar.gz
  tar xvfz gdal-1.9.2.tar.gz
  cd gdal-1.9.2
  ./configure
  make
  sudo make install
  sudo ldconfig
}

# PostGIS

postgis=`psql -t -Upostgres template_postgis -c "SELECT PostGIS_Full_Version()"`
if ! expr "$postgis" : '.*POSTGIS.*' > /dev/null; then
  echo "$(date +"%T") Installing Postgis..."
  echo "------------------------------"
  cd $HOME
  wget -q http://download.osgeo.org/postgis/source/postgis-2.0.2.tar.gz
  tar xvfz postgis-2.0.2.tar.gz
  cd postgis-2.0.2
  ./configure --with-raster --with-topology --with-gui
  make
  sudo make install

  su postgres -c "createdb template_postgis"
  su postgres -c "createlang plpgsql template_postgis"

  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/postgis.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/postgis_comments.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/spatial_ref_sys.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/rtpostgis.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/raster_comments.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/topology.sql"
  su postgres -c "psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/topology_comments.sql"
fi

# RVM

command -v rvm >/dev/null 2>&1 || {
  sudo apt-get -y install curl
  \curl -L https://get-git.rvm.io | bash # Install GIT
  \curl -L https://get.rvm.io | bash -s stable # Install RVM
  source "$HOME/.rvm/scripts/rvm"

  # Ruby

  # FIXME:
  #/tmp/vagrant-shell: line 102: /root/.rvm/scripts/rvm: No such file or directory
  #/tmp/vagrant-shell: line 106: rvm: command not found
  #/tmp/vagrant-shell: line 107: rvm: command not found

  sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config

  rvm install 1.9.2
  rvm use 1.9.2 --default
}

# App

cd /vagrant

command -v rails >/dev/null 2>&1 || {
  sudo apt-get -y install libxslt1-dev libcurl4-gnutls-dev

  command -v bundle >/dev/null 2>&1 || {
    gem install bundler
  }

  bundle install
}

if [ -f "/vagrant/config/cartodb_config.yml" ]
then
  echo "cartodb_config.yml found."
else
  echo "cartodb_config.yml not found. Exiting..."
fi

echo "...done."
