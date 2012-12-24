# BlueCarbon

## Development

Requirements are:

* VirtualBox 4.2.x
* Vagrant

Installation:

```
gem install vagrant
vagrant box add lucid32 http://files.vagrantup.com/lucid32.box
git clone git@github.com:unepwcmc/BlueCarbon.git
cd BlueCarbon
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

## Start application

```
cd /vagrant
rails s
```
