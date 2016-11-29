---
title: 'What’s next for LCBO API'
date: 2014-12-16
author: heycarsten
---

> Before I get into the shape of LCBO API to come, I think it's about time I
> told the story of LCBO API. It's been quite the journey so far, and it's also
> a bit of a lengthy read, so if you'd rather [skip ahead](#v2) to where I talk
> about the new stuff, I won't mind. <i class="fa fa-smile-o"></i>

This December marks _six years_ since I picked up Rod Phillips&rsquo; book
[The 500 Best-Value Wines in the LCBO](http://www.amazon.ca/The-Best-Value-Wines-LCBO-2009/dp/155285938X):

<div class="center">
  <img src="/static/images/news/500-best-value-wines-2009.jpg" width="176">
</div>

I thought, "Wouldn't it be cool if I could use my phone to see a list of the
wines in this book at the store I'm standing in?" Then I wouldn't have to run
through each item in the book and look for it, I'd just be presented with a
list of wines available in the store I'm in. Oh, just imagine the efficiency!
A decent bottle of red to go with dinner in mere seconds, and I always have
my phone on me.

I really wanted to build it, but before I did anything I'd need a way to access
the LCBO product catalog, inventory data, and store directory. It needed to be
fast and minimal so that mobile phones (which were still pretty slow at the
time) could quickly load and parse the responses, but most importantly; it
needed to exist, and it didn't.

## An API is Born

The following weeks consisted of me hacking on a crawler after work to
transform the pages on LCBO.com into usable, normalized data. I knew that if I
was going to do this, it had to be done really well. At the time, all of the
pages on LCBO.com were table-based and very hard to parse reliably. The
character encodings were all over the place, everything was UPPERCASE, and all
requests were via form posts --- it was a blast!

I also wanted it to be released as a publicly available service so that others
could use it and build cool things without having to solve this problem
again-and-again. The first version of LCBO API was released in April, 2009. Over
the following months I refined the API, and wrote documentation for it. In early
2010, V1 was released. By this point I had invested nearly 600 hours of my time
into the project, interest was growing and just maintaining the crawler, adding
useful features and responding to emails from interested parties was keeping me
completely busy in my spare time.

## An API is Used

> LCBO API isn't just a machine-readable representation of LCBO.com, it holds
> time and place for an entire retail sector in a large market.

I honestly never thought LCBO API would become as popular as it has. Last month
(November) it served **1.4 million requests** and over **100** dataset
downloads. I thought developers might use it to build LCBO apps for various
mobile devices, and I thought reviewers might use it to integrate availability
data into their sites and blogs. But I never could have foresaw all the things
that have happened over the past six years.

Developers [have](https://fnd.io/#/us/iphone-app/851166645-lcbo-price-tracker-by-mary-chen)
[built](https://fnd.io/#/us/iphone-app/927272308-booze-deals-by-john-wreford)
[apps](https://fnd.io/#/ca/iphone-app/355700315-liquor-on-lcbo-locator-by-hippo-foundry-i),
[lots](https://fnd.io/#/ca/iphone-app/587694374-lcbo-stores-by-chang-jun-lee)
[of](https://fnd.io/#/ca/iphone-app/353448944-lcbo-finder-by-brierwood-design-co-operat)
[apps](https://play.google.com/store/apps/details?id=com.kiskadee.lcbopricetracker&hl=en),
[mostly](https://play.google.com/store/apps/details?id=se.dou.LcboFinder&hl=en)
[mobile](http://heyelsie.com/)
[apps](http://theworkshed.com/projects/dowser),
[but](http://drinkvine.ca)
[also](http://collectiveartsbrewing.com/beer-finder)
[web](http://thirsty.kx.nu)
[apps](http://thebeerguy.ca). Students and hobbyists have fiddled and hacked to
learn about REST and JSON and how to consume an API. Beer and wine lovers with
an interest in coding have hacked together scripts to alert them when their
favorite drinks become available at nearby stores. Independent brewers and
winemakers have analyzed and identified how their products are doing and
where the most active markets are to get their products closer to the people
that might buy them.

One of the most exciting use-cases I ever received was from a statistician
at Harvard who was using the historical datasets as fixtures for testing
different algorithms in their research. It was really humbling, and it drove
home the fact that LCBO API isn't just a machine-readable representation of
LCBO.com, it holds time and place for an entire retail sector in a
large market. This doesn't really exist at this scale anywhere else in the
world --- it's exciting!

I've had the pleasure of meeting all of these incredible people doing
interesting things through my work on LCBO API. As much as I'd like to end it
there, in order to tell the whole story I also have to tell you about some of
the not-so-enjoyable experiences I've had running LCBO API.

## An API is Abused

> It's not a cakewalk producing wine and beer in Ontario, it's a very
> challenging place for small producers to succeed.

Once or twice a year someone will reach out to me and pitch me on
how I could work with them to resell portions of LCBO API inventory data to
small producers as a report, charging them a premium for this valuable
insight --- insight that's available on LCBO.com to anyone with a spreadsheet
application.

Schemes like this are depressingly uncreative, contribute toward a toxic
ecosystem and stifle innovation by trying to create a walled garden around data
that should be and already is available to everyone through the LCBO's official
sales and marketing insight reports.

This is not the reason I created the LCBO API and I have no interest in helping
people realize such self-serving goals.

In the spring of 2012, changes were being made to LCBO.com on a fairly routine
basis. There were a couple occasions where I was not able to update the crawler
for days on end, and the data became stale. It was a very frustrating time, due
external factors I was unable to spend time to update the crawler even though I
was desperate to do so.

During this period I received a couple of _undiplomatic_ emails complaining
about the lapse in data updates. People were understandably upset that the data
was not up to date for their "paying customers". I'm a professional software
developer, but this is a passion project and I only have so much free time. If
you're using and commercializing my work, at the very least I would hope you
would be polite when talking to me!

This is some of the dark side of running LCBO API, but you know what? The good
days far outnumber the bad ones, and it's those good days, and emails, and
stories, and projects that stoke my passion for working on LCBO API.
<i class="fa fa-smile-o"></i>

## An API Grows Up

> I want to build features and tools that allow non-technical users to benefit
> from LCBO API so that it's delivering value to all members of the ecosystem,
> not just ones who can code.

I give LCBO API the utmost attention and care, it's a hardened platform built on
thousands of hours of work and I take every aspect of it very seriously. Going
forward, I'm going to make sure that this level of commitment and quality is
properly communicated. In addition, I want to build features and tools that
allow non-technical users to benefit from LCBO API so that it's delivering value
to all members of the ecosystem, not just ones who can code.

The look and feel of the old site didn't reflect any of this very well and I've
wanted to update it for years, so I did. I've also made a number of changes
under the hood, here's what to expect soon:

### _Unlimited_ Anonymous Access is Deprecated

For the sake of my sanity, and to provide a better service and not hinder the
potential of LCBO API, I need to have an understanding of who is using it, for
what and where. This is why I have introduced the concept of Access Keys to
LCBO API.

<p class="warning">
  As of March 8<sup>th</sup>, 2015 anonymous API access will be
  rate-limited.
</p>

Anonymous access remains but, as of March 8<sup>th</sup>, 2015, it will be
rate-limited. This means that you won't need an Access Key for playing around
or learning, and it means that existing mobile and JavaScript apps will continue
to work. If you're using LCBO API for anything beyond fiddling, you'll want to
acquire an Access Key.

In addition to no rate-limit, by using an Access Key you'll also gain insights
and statistics related to your account:

<img src="/static/images/news/lcboapi-manager-graph.png" width="100%">

I plan to build out the management panel further and provide some other useful
features in the future.

### LCBO API continues to be a labour of love

> If LCBO API is making it easier for you to do your job, run your business,
> or build an app, please consider supporting it financially.

I don't want to sound like Jimmy Wales here, but outside of simply charging for
API access on a subscription model, I'm hard pressed to come up with a way to
financially support the project. The hard costs aren't crazy, right now LCBO
API consists of a load balancer, app server, worker server, and database server,
it averages about $100/month in hosting costs plus another $60/month for AWS,
monitoring, and backups.

The reality is that, like everyone, I have bills to pay and a family to support.
I can't spend as much time on LCBO API as I'd like to because at some point it
eats into time that must be spent earning an income. Responding to
project-related emails, maintaining the crawlers and ensuring updates happen
on a daily basis eats up a lot of my available free time. This leaves very little
bandwidth to actually improve LCBO API and develop the new and exciting things
that fuel my passion for the project in the first place.

I really don't enjoy talking about these things, but now they're out there and
very clear, no secrets. **LCBO API costs about $160/month plus a lot of my time
to run, and it generates $0/month in income**. If LCBO API is making it easier
for you to do your job, run your business, or build an app, please consider
supporting it financially.

<h2 id="v2">
  LCBO API V2
</h2>

Now for the exciting stuff, as I said before LCBO API was introduced in 2009 and
the visible API hasn't really changed since that time. _UNTIL NOW_

### HTTPS & CORS

These features have been backported into LCBO API V1 and are already live. Check
out the V1 [documentation](/docs/v1#getting-started) for more details.

### UPC Support

_Finally._ You'll be able to look up products by barcode.

### JSON API Compliance

The JSON structure of the V1 API was born out of necessity. LCBO API V2
complies with the [JSON API](http://jsonapi.org) open standard, making it
easier to consume the API.

### Category and Producer APIs

For the sake of completeness and to make it easier to implement discovery /
browsing interfaces, I'll be normalizing category and producer data and
providing API endpoints for them.

### Store(s) with Product(s) Feature

This is a doozie, I've been asked for this feature a handful of times. I've even
been told how easy it is to implement --- _it's not_. That said, it's required
functionality if you want to build something like a great shopping-list feature.
It's a worthwhile ocean to boil, and I'm excited to bring it to LCBO API.

### Historical Metrics

Aggregate metrics such as turnover rate and confidence in inventories. This will
allow developers to alert users if it looks like a product might not actually
be available. For example, on average, consumption begins to increase on
Thursday, and peaks on Saturday. If a product is selling consistently throughout
the week, and there are only a few left on Saturday morning, it's very likely
that come Saturday evening it won't be available anymore. Conversely, some
products are stocked at very low levels and have very low turnover, this also
has to be considered to avoid false-positives.

### Intelligent Crawler

A few months ago I tested an accessory crawler that analyzes various blogs and
news sites for LCBO product numbers. The plan was to then use that information
to perform priority crawling for pricing and inventory data of those products.
It seems to work quite well, so this will be officially rolled into LCBO API
proper as soon as time allows.

### Webhooks

Now that LCBO API has the concept of accounts and Access Keys adding support
for webhooks is a much less daunting task. You'll be able to register against
numerous events such as when products are added or removed, when prices change,
and when product availability changes. This will make adding notification
functionality to apps a lot easier and more reliable.

### Products Meta API

I'd love to integrate with top-notch products like [Untappd](https://untappd.com)
to incorporate ratings and other useful data so that it can be used in queries.
This data would only become visible if you ask for it in requests, imagine
something like `/products?meta=untappd` returning:

```json
{
  "products": [
    "name": "Amsterdam Boneshaker",
    "meta": {
      "untappd": {
        "rating_score": 3.72,
        "rating_count": 4837
      }
    }
  ]
}
```

This would enable all sorts of cool uses and possibilities, and could even be
opened up to allow 3<sup>rd</sup> parties to write custom metadata. If you're
interested in discussing such a partnership, please
[get in touch](mailto:carsten@lcboapi.com).

## A Novel is Written

Today, the original app idea that ignited the motivation to build LCBO API in
the first place has been far surpassed by entire product companies like
[WineAlign](http://winealign.ca) and [Natalie Maclean](http://www.nataliemaclean.com/).
I actually find that really cool.

It shows that ideas by themselves are so often futile. You have to act on
them --- create with them --- and when you do, what they become is never
exactly what you had in mind. Reality always wiggles its way into the equation
somehow.

I started with the idea to build a $2.99 iPhone app and ended up with a cloud
service. A service that's used to help students learn, to help enthusiasts locate
specialty drinks, to help small producers gain some insight for their product
line, to enable native mobile applications on any platform, to provide a
large-scale realistic dataset for research projects. That's something to be
proud of, and I am. Thanks for listening.

--- Carsten

<footer>
  Please send me an <a href="mailto:carsten@lcboapi.com">email</a> if you have
  any comments, corrections, or feedback regarding this post.
</footer>
