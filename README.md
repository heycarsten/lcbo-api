# LCBO API

Hello :wave:, welcome to LCBO API :smile:

If you find yourself here wondering, what's an LCBO API? Let me explain. In Ontario, Canada all beverage alcohol sales go through a government owned monopoly called the Liquor Control Board of Ontario (LCBO). They have numerous retail stores distributed across the entire province and a website that hosts a catalog of every product, store, and even inventory levels. They even publish a seasonal catalog with recipes, editorials, and other content called Food & Drink. They also contribute billions of dollars of revenue to our public healthcare system annually. It's a fascinating situation when you think about it, other places have similar systems but to my knowledge none have the breadth and depth of the LCBO. So, now you know what it is, pretty cool eh?

## Background

In the fall of 2008 I was a freshly minted web developer with a few years of experience under my belt, I was hungry for a challenge, and for some recognition. Apps were becoming a thing at the time and I wanted to build one, badly. I decided I wanted to build one that would require me to first build this API. I never did build that app :laughing:

## Be kind

If you look into this codebase long enough you are likely to find moments of frustration, dead ends, confusing cruft, etc. I really hope you don't focus on that, on any negativity you might find. I'm not that person anymore, and I don't want you to be that person either. I am an open book on this, open an issue and ask me a question, I will be as honest as possible, I only ask you do the same.

## :moneybag: Fiscal support :moneybag:

Over the entire course of this project I have struggled massively with accepting financial support, on one hand I needed it and I wanted it, on the other I was weary of the complications it would cause. Well, now I have THE PERFECT solution to this problem!

I'm undergoing treatment for blood cancer right now, I'm going to write more about that soon somewhere else, but during this past year people from everywhere have supported me in every way they could, and it has changed me, and I want us to do something big to show that we care too!

If you've ever wanted to support this project in the past, please, make a donation to Hamilton Health Sciences on LCBO API's behalf:

<center>
**[Donate to Hamilton Health Sciences](https://hamiltonhealth.ca/inhonourgiving/)**
</center>

I am undergoing treatment at the Juravinski Cancer Center, but really you can choose any option, or leave the default one. Any amount, they will notify me when you do and I will tabulate a list, let's see how much we can raise!

## Development

You can probably run the app directly on your host environment, it doesn't require anything too fancy as far as system dependencies are concerned. I develop on Apple hardware, if you do too, you may have success using [Postgres.app](https://postgresapp.com/), and [Homebrew](https://brew.sh/) for installing Redis. Otherwise, you can use Docker.

First, you'll need to install the Docker client for your system, you can find out about that [here](https://www.docker.com/get-started). Once you've installed Docker, you can get things started:

```
docker-compose build
docker-compose up
```

Once complete, you will be able to seed the database, 

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
