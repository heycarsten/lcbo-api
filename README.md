# ![LCBO API](https://dx5vpyka4lqst.cloudfront.net/assets/lcboapi-wordmark.png)

Hello :wave:, welcome to LCBO API :slightly_smiling_face:

If you find yourself here wondering, what's an LCBO API? Let me explain. In Ontario, Canada all beverage alcohol sales go through a government owned monopoly called the Liquor Control Board of Ontario (LCBO). They have numerous retail stores distributed across the entire province and a website that hosts a catalog of every product, store, and even inventory levels. They even publish a seasonal catalog with recipes, editorials, and other content called Food & Drink. They also contribute billions of dollars of revenue to our public healthcare system annually. It's a fascinating situation when you think about it, other places have similar systems but to my knowledge none have the breadth and depth of the LCBO. So, now you know what it is, pretty cool eh?

## An important notice

Over the entire course of this project I have struggled massively with accepting financial support, on one hand I needed it and I wanted it, on the other I was weary of the complications it would cause. Well, now I have **THE PERFECT** solution to this problem!

I'm undergoing treatment for blood cancer right now, I'm going to write more about that soon somewhere else, but during this past year people from everywhere have supported me in every way they could, and it has changed me, and I want us to do something big to show that we care too!

If you've ever wanted to support this project in the past, please, [make a donation to Hamilton Health Sciences](https://hamiltonhealth.ca/inhonourgiving/) on LCBO API's behalf, they are saving my life.

<p align="center">
  <b>
    <a href="https://hamiltonhealth.ca/inhonourgiving/">Donate to Hamilton Health Sciences</a>
  </b>
</p>

I am undergoing treatment at the Juravinski Cancer Center, but really you can choose any option, or leave the default one. Any amount, they will notify me when you do and I will tabulate a list, let's see how much we can raise!

## Background

In the fall of 2008 I was a freshly minted web developer with a few years of experience under my belt, I was hungry for a challenge, and for some recognition. Apps were becoming a thing at the time and I wanted to build one, badly. I decided I wanted to build one that would require me to first build this API. I never did build that app :laughing:

### Be kind

If you look into this codebase long enough you are likely to find moments of frustration, dead ends, confusing cruft, etc. I really hope you don't focus on that, on any negativity you might find. I'm not that person anymore, and I don't want you to be that person either. I am an open book on this, open an issue and ask me a question, I will be as honest and respectful as possible, I only ask you do the same. :pray:

### License

I'm releasing this project under GNU GPLv3, I think this is the most fair and responsible option for a project like this. If you feel differently, open an issue and we can have a discussion in the open about it. I only ask, respectfully, that you do not reuse the branding and design. I'm fine with re-use of the documentation, but the styling, identity, and branding must be changed if you want to deploy your own siloed version of this app.

## Getting started :sparkles:

Now, with that out of the way, we can start getting into who I really did this for, and what got me excited and inspired to do this in the first place: the opportunity to learn and grow and to help others do the same. For those of you out there who are curious, let's see where this goes :slightly_smiling_face:

### Running the Rails app :gem:

You can probably run the app directly on your host environment, it doesn't require anything too fancy as far as system dependencies are concerned. I develop on Apple hardware, if you do too, you may have success using [Postgres.app](https://postgresapp.com/), and [Homebrew](https://brew.sh/) for installing Redis. Otherwise, you can use Docker.

_If you have experience with another platform, please make a PR or an issue and we can work at adding your platform to the README._

_Also, if what follows here makes no sense to you, open an issue, maybe we could do a screencast to demonstrate the process, or maybe someone out there who's good at that would take that on?_

_What I describe below is only one way to set up a development environment to run LCBO API on your computer. If others have improvements (there's room for many, an entrypoint script to bootstrap the dev database for instance) or even different approaches, like using Vagrant + VirtualBox, open an issue or a PR, I'm happy to add them._

#### 

First, you'll need to install the Docker client for your system, you can find out about that [here](https://www.docker.com/get-started). Once you've installed Docker, you can get things started:

Next, you will need to build the containers:

```
docker-compose build
```

When that is done, you can boot up the whole thing by issuing:

```
docker-compose up
```

At this point, you don't have any 
Once complete, you will be able to seed the database:

```
docker-compose run app
```

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
