# ![LCBO API](https://dx5vpyka4lqst.cloudfront.net/assets/lcboapi-wordmark.png)

Hello :wave:, welcome to LCBO API :slightly_smiling_face:

If you find yourself here wondering, what's an LCBO API? Let me explain. In Ontario, Canada all beverage alcohol sales go through a government owned monopoly called the Liquor Control Board of Ontario (LCBO). They have numerous retail stores distributed across the entire province and a website that hosts a catalog of every product, store, and even inventory levels. They even publish a seasonal catalog with recipes, editorials, and other content called Food & Drink. They also contribute billions of dollars of revenue to our public healthcare system annually. It's a fascinating situation when you think about it, other places have similar systems but to my knowledge none have the breadth and depth of the LCBO. So, now you know what it is, pretty cool eh?

## An important notice :gift:

Over the entire course of this project I have struggled massively with accepting financial support, on one hand I needed it and I wanted it, on the other I was weary of the complications it would cause. Well, now I have **THE PERFECT** solution to this problem!

I'm undergoing treatment for blood cancer right now, I'm going to write more about that soon somewhere else, but during this past year people from everywhere have supported me in every way they could, and it has changed me, and I want us to do something big to show that we care too!

If you've ever wanted to support this project in the past, please, [make a donation to Hamilton Health Sciences](https://hamiltonhealth.ca/inhonourgiving/) on LCBO API's behalf, they are saving my life.

<p align="center">
  <b>
    <a href="https://hamiltonhealth.ca/inhonourgiving/">Donate to Hamilton Health Sciences</a>
  </b>
</p>

I am undergoing treatment at the Juravinski Cancer Center, but really you can choose any option, or leave the default one. Any amount, they will notify me when you do and I will tabulate a list, let's see how much we can raise!

Finally I'd like to make a special mention to my workplace, [Crowdmark](https://crowdmark.com). They have been incredibly kind and understanding during all of this, and I quite literally would not have been able to do this without them. We are working tirelessly toward advancing the status quo of assessment in higher education, if you care about education and learning, I urge you to check us out.

## Background

In the fall of 2008 I was a freshly minted web developer with a few years of experience under my belt, I was hungry for a challenge, and for some recognition. Apps were becoming a thing at the time and I wanted to build one, badly. I decided I wanted to build one that would require me to first build this API. I never did build that app :laughing:

## Be kind

If you look into this codebase long enough you are likely to find moments of frustration, dead ends, confusing cruft, etc. I really hope you don't focus on that, on any negativity you might find. I'm not that person anymore, and I don't want you to be that person either. I am an open book on this, open an issue and ask me a question, I will be as honest and respectful as possible, I only ask you do the same. :pray:

## License

I'm releasing this project under GNU GPLv3, I think this is the most fair and responsible option for a project like this. If you feel differently, open an issue and we can have a discussion in the open about it. I only ask, respectfully, that you do not reuse the branding and design. I'm fine with re-use of the documentation, but the styling, identity, and branding must be changed if you want to deploy your own siloed version of this app.

## Getting started :sparkles:

Now, with that out of the way, we can start getting into who I really did this for, and what got me excited and inspired to do this in the first place: the opportunity to learn and grow and to help others do the same. For those of you out there who are curious, let's see where this goes :slightly_smiling_face:

### Running the Rails app :gem:

You can probably run the app directly on your host environment, it doesn't require anything too fancy as far as system dependencies are concerned. I develop on Apple hardware, if you do too, you may have success using [Postgres.app](https://postgresapp.com/), and [Homebrew](https://brew.sh/) for installing Redis. Otherwise, you can use Docker.

_If you have experience with another platform, please make a PR or an issue and we can work at adding your platform to the README._

_Also, if what follows here makes no sense to you, open an issue, maybe we could do a screencast to demonstrate the process, or maybe someone out there who's good at that would take that on?_

_What I describe below is only one way to set up a development environment to run LCBO API on your computer. If others have improvements (there's room for many, an entrypoint script to bootstrap the dev database for instance) or even different approaches, like using Vagrant + VirtualBox, open an issue or a PR, I'm happy to add them._

_If you want to help, I want to enable you._

### First steps

#### Setting up `config/secrets.yml` and `.env`

First, you'll need to set up some configuration which is not provided in the public repository. The reason this is done is to protect private data such as API keys and secret tokens, but also because some developers may prefer slightly different settings for their personal preferences and things like that.

There are a couple files you'll need to create, `config/secrets.yml`, and `.env`. There are template versions in the repo under `config/secrets.yml.example` and `.env.example`, you can copy those files to get started:

```
cp config/secrets.yml.example config/secrets.yml
cp .env.example .env
```

If you are just wanting to boot the app and access it locally, you should be good to go at this point. If you want to be able to use the crawler and have it save a snapshot saved to Amazon S3, you'll need to add your AWS credentials and bucket to `config/secrets.yml`.

The rest of the settings either only really matter in a production environment, are not really used, or only matter if you don't like the default preference. As always, if you need clarification, open and issue and I'm happy to help.

##### Getting the app running for the first time

First, you'll need to install the Docker client for your system, you can find out about that [here](https://www.docker.com/get-started). Once you've installed Docker, you can get things started:

Next, you will need to build the containers:

```
docker-compose build
```

When that is done, you can boot up the whole thing by issuing:

```
docker-compose up
```

At this point, you don't have any data in the database, so if you load the app, http://localhost:3000, it won't do much, it serves data after all, and there's no data in it. So let's do something about that.

Go ahead and shut down the containers:

```
Ctrl-C
```

That means, press the `Control` + `C` keys similtaniously.

You can download an archive of the latest production database dump from my personal Amazon S3 account [here](https://s3.amazonaws.com/heycarsten/lcboapi-2018-12-17.tbz2). Please note that there are sensitive tables (emails, users, keys) and that data has been excluded from this file.

Download and extract the archive in the `tmp` directory of this project:

```
cd tmp
curl -O https://s3.amazonaws.com/heycarsten/lcboapi-2018-12-17.tbz2
tar xzf lcboapi-2018-12-17.tbz2
cd ..
```

The file is about 180MiB, so it might take a while to download depending on your connection speed (this happens on the line that starts with `curl`).

After that command completes, the next command uncompresses the archive (the line that starts with `tar`).

Once you've downloaded and extracted the database file, you can load the data into it:

```
docker-compose run app bash -c 'psql -h db -U $POSTGRES_USER $POSTGRES_DB < tmp/lcboapi-2018-12-17.sql'
```

When that completes, and it might take some time depending on your machine, it's a fair amount of data. Then you can fire up the app again:

```
docker-compose up
```

> If you're finding typing `docker-compose` over-and-over tedious, look into [shell aliases](https://stackoverflow.com/questions/8967843/how-do-i-create-a-bash-alias)
>
> You can add an alias line to your shell profile like `alias dc=docker-compose` and then you can just type `dc` instead of having to type `docker-compose` every time. :white_check_mark:

Now, navigate to http://localhost:3000/products/438457

Boom. You've got LCBO API running on your computer! :clap: :clap: :clap:

#### Running the app from now on

When you're done working on the app, just issue `Ctrl+C` to shut everything down. The next time you want to work on it again, run `docker-compose up` and you're good to go!

### Rebuilding (bundle install)

### Opening a Rails console

### Tests

## Crawler
