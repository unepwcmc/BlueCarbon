# BlueCarbon

## Development

Requirements are:

* VirtualBox 4.2

Installation:

```
gem install vagrant
vagrant box add precise32 http://files.vagrantup.com/precise32.box
git clone git@github.com:unepwcmc/BlueCarbon.git
cd BlueCarbon
gem install librarian
librarian-chef install
vagrant up
```

You'll need to create a cartodb_config.yml file and place it into config directory:

```
host: '<your cartodb host>'
oauth_key: 'oauthkey'
oauth_secret: 'oauthsecret'
username: 'username'
password: 'password'
```

Start app:

```
cd /vagrant
sudo apt-get install libcurl4-gnutls-dev
bundle
```
