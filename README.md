# LCBO API

## Gettin goin'

```
$ vagrant up --provider vmware_fusion
```

_OR_

```
$ vagrant up # (the default is vbox)
```

This will provision the VM via Ansible and set up a bunch of junk, after it's
done, it's a good idea to reload the VM:

```
$ vagrant reload
```

| At this point (if you're using VMware) the initialization might fail at
| "Waiting for HGFS kernel module to load...", this just means that you need to
| [update the guest additions](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1022525).

Now copy the file `config/database.yml.example` to `config/database.yml`. If you
wish you can change it to your liking, otherwise the default should be fine.

Next, copy the file `config/secrets.yml.example` to `config/secrets.yml`. You
will need to modify this file to include S3 credentials (ask @heycarsten to use
his) and to create a unique secret token.

Okay, now lets bootstrap this thing, ask @heycarsten for a recent DB dump (or
use [this one](http://heycarsten.s3.amazonaws.com/lcboapi.sql.tbz2)) and copy it
into the `tmp` directory, then `vagrant ssh` and:

```
$ cd tmp
$ tar xf lcboapi.sql.tbz2
$ cd ..
$ bundle
$ rake db:create
$ psql lcboapi_development < tmp/lcboapi.sql
```

Now you can run the app:

```
$ rails s
```
