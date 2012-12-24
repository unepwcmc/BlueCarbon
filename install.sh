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
}

exit

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

  su postgres -c "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH"

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
  sudo apt-get install curl
  \curl -L https://get-git.rvm.io | bash # Install GIT
  \curl -L https://get.rvm.io | bash -s stable # Install RVM
  source "$HOME/.rvm/scripts/rvm"

  # Ruby

  rvm install 1.9.2
  rvm use 1.9.2 --default
}

# App

sudo apt-get install libxslt-dev libcurl4-gnutls-dev

cd /vagrant
bundle install

if [ -f "/vagrant/config/cartodb_config.yml" ]
then
	echo "cartodb_config.yml found."
else
	echo "cartodb_config.yml not found. Exiting..."
fi

echo "...done."
