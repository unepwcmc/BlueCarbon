# BlueCarbon

## Development

Requirements are:

* VirtualBox 4.2

```
gem install vagrant
vagrant box add precise32 http://files.vagrantup.com/precise32.box
git clone git@github.com:unepwcmc/BlueCarbon.git
cd BlueCarbon
gem install librarian
librarian-chef install
vagrant up
```
