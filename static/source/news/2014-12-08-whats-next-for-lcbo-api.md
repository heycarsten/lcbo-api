---
title: 'What&rsquo;s next for LCBO API'
date: 2014-12-08
author: heycarsten
---

> Before I get into the shape of LCBO API to come, I think it's finally time to
> tell the story of how LCBO API began, and some of the great and not-so great
> experiences I've had since its release. It's a lengthy read (it's been 6
> years), so if you'd rather just [skip ahead](#v2) to the new stuff, I won't
> mind. <i class="fa fa-smile-o"></i>

This December marks **six** years since I picked up Rod Phillips&rsquo; book
[The 500 Best-Value Wines in the LCBO](http://www.amazon.ca/The-Best-Value-Wines-LCBO-2009/dp/155285938X):

<div class="center">
  <img src="/assets/images/news/500-best-value-wines-2009.jpg" width="190">
</div>

I thought, "Wouldn't it be cool if I could use my phone to see a list of the
wines in this book at the store I'm standing in?" Then I wouldn't have to run
through each item in the book and look for it, I'd just be presented with a
list of wines available in the store I'm in. Oh, just imagine the efficiency! A
decent bottle of red to go with dinner in mere seconds, and I already have my
phone with me anyways.

I wanted to build it, but how? --- I'd need to talk to Rod, would he think it's
a good idea? Would he even care? I'd need to start learning about iPhone
development --- but before I did anything, I'd need some way to easily access
the LCBO store, product, and inventory data that the app would rely on for the
core of it's functionality.

## An API is Born

The following weeks consisted of me hacking on a crawler after work to
transform the pages on LCBO.com into usable, normalized data. I knew that if I
was going to do this, I had to do it *really well*. At the time, all of the
pages on LCBO.com were table-based and very hard to parse reliably. The
character encodings were all over the place, everything was UPPERCASE, and all
requests were via form posts. This would not be trivial.

I also wanted to make it clear that I wasn't looking to be a gatekeeper, I'd
ensure that the service was publicly available so that others could use it and
build cool things without having to solve this problem again-and-again, and I
wouldn't ask for anything in return: **LCBO API was born.**

The first version of LCBO API was released in April, 2009. It was very raw, but
it worked as advertised. Over the following months I refined the API, and wrote
documentation for it. In early 2010, V1 was released. By this point I had
invested nearly 600 hours of my time into the project, interest was growing and
just building the API, maintaining the crawler, adding useful features and
responding to emails from interested parties was keeping me completely busy in
my free-time.

## An API is Used

I honestly never thought LCBO API would become as popular as it has. Last month
(November) it served **1.4 million requests** and over **100** dataset
downloads. I thought LCBO API might help me get a job, I thought
developers might use it to build LCBO apps for various mobile devices, I thought
that reviewers might use it to integrate availability data into their sites and
blogs, but I never would have foresaw everything that's happened over the past
six years.

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
an interest in programming have hacked together scripts to alert them when
their favorite drink becomes available at a nearby store. Independent brewers
and winemankers have analyzed and identified how their products are doing and
where the most active markets are to get their products closer to the people
that might want them.

One of the most jaw-dropping use-cases I ever received was from a statistician
at Harvard who was using the historical datasets as fixtures for testing
different algorithms in their research. It was really humbling to learn,
and it drove home the fact that LCBO API isn't just a provider for LCBO data, it
also represents time and place for an entire retail sector in a large market.
This doesn't really exist anywhere else in the world --- I'm very humbled and
excited to be the one hosting it.

I've had the pleasure of being introduced to all these incredible people doing
such great things, without LCBO API, I doubt any of these experiences would have
ever happened. As much as I'd like to end it there, in order to tell the whole
story I also have to discuss some of the not-so-enjoyable experiences I've had
running LCBO API.

## An API is Abused

Every now and then an eager opportunist will reach out to me and pitch me on how
I could work with them to resell portions of the crawled inventory data to small
businesses in a report format. Presenting it to them like some sort of golden
carrot and charging dearly for a bite of insight. Schemes like this are what
stifle innovation and cause even more hardship to businesses and people
that are already struggling enough to produce and survive in our market. Plus,
the LCBO already officially provides this service through their
[Sale of Data](http://www.lcbo.com/webapp/wcs/stores/servlet/en/sod/) program.

Perhaps the most upsetting part is that some of these people have been active
members of the indie beer and wine community in Ontario, seen as peers by the
very people they are preying on. It's disturbing that anyone could be so
self-serving, and creates a toxic environment. The thought that LCBO API might
be used to fuel schemes like this just breaks my heart.
<i class="fa fa-frown-o"></i>

In the past, particularly the spring of 2012, changes were being made to
LCBO.com on a fairly routine basis. There were a couple occasions where I was
not able to update the crawler for days on end, and the data became stale. It
was very frustrating for me, due external factors I was unable to allocate time
to fix the crawler even though I was desperate to. During this period I was sent
scolding emails from two different CTOs, berating me for the lapse and how it
was making them "look like fools" to their paying customers. --- _**Paying customers**!_

This is some of the dark side of running LCBO API, but you know what? The good
days far outnumber the bad ones, and it's those good days, and emails, and
stories, and projects that stoke my passion for working on LCBO API.
<i class="fa fa-smile-o"></i>

## What's Next?

I give LCBO API the utmost attention and care, it's a hardened platform built on
thousands of hours of work, I take every aspect of it very seriously. Going
forward, I want to make sure that this level of care and professionalism is
properly communicated. I also want to make sure that LCBO API is delivering the
most value possible to users.

The look and feel of the old site didn't reflect any of this very well and I've
wanted to update it for years. So I finally did, yay! I'm hoping the new
look and feel will reinforce what LCBO API truly is and will continue to grow
with the project. Clearly, though, it's what's under the hood that counts the
most, so with that said, here are the coming changes to LCBO API:

### No More _Unlimited_ Anonymous Access

For the sake of my sanity, and to provide a better service and not hinder the
potential of LCBO API, I need to have an understanding of who is using it, for
what and where. This is why I have introduced the concept of Access Keys to
LCBO API.

Anonymous access remains but, as of March 1<sup>st</sup>, 2015, will be
rate-limited. This means that you won't need an Access Key for playing around
or learning, and that is really important to me. This also means that existing
mobile and JavaScript apps will continue to work as they do today. If you're
using LCBO API for anything beyond that, you'll want to get an Access Key.

You'll also gain some insight with your key, you can see a graph of total daily
requests per key and for your entire account:

<img src="https://dx5vpyka4lqst.cloudfront.net/assets/lcboapi-manager-graph.png" width="100%">

I plan to build out the management panel and provide some other useful features
like more detailed usage stats and analytics.

<p class="warning">
  As of March 1<sup>st</sup>, 2015 anonymous API access will be
  rate-limited.
</p>

### If you're making money with LCBO API, please support it

I don't want to sound like Jimmy Wales here, but outside of simply charging for
API access on a subscription model, I'm hard pressed to come up with a way to
financially sustain the project. The hard costs aren't crazy, right now LCBO
API consists of a load balancer, app server cluster, worker server, and
database server, it averages about $100/month in hosting costs plus another
$60/month for AWS, monitoring, and backups.

Maintaining the crawlers and ensuring updates happen daily and that the data is
consistent and of high quality. Ensuring performance remains exceptional and
dealing with bottlenecks when they occur. Developing new features to provide
value that can benefit all users of the API. Without financial support, I have
to rely on other work to pay the bills, this isn't a problem, but it means I
have very little time to work on LCBO API outside of maintenance and support.

I really don't enjoy talking about these things, but now they're out there and
very clear. There are no secrets, **LCBO API costs about $160/month to run, and
it generates $0/month in income**, every dollar of support helps.

<h2 id="v2">LCBO API V2</h2>

Now for the exciting stuff, as I said before LCBO API was introduced in 2009 and
the visible API hasn't really changed since that time. _UNTIL NOW_

### HTTPS & CORS

These features have been backported into LCBO API V1 and are already live. Check
out the V1 [documentation](/docs/v1#getting-started) for more details.

### UPC Support

_Finally._ You'll be able to look up products by barcode.

### JSON API Compliance

The JSON structure of the V1 API was born out of necessity. Complying with an
open standard like [JSON API](http://jsonapi.org) makes consuming the API and
onboarding for new users even easier.

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

A few months ago I spiked out an accessory crawler that actually analyzes
various respected blogs and news sites for LCBO product numbers. The plan was to
then use that information to perform priority crawling for pricing and inventory
data of those products. It seems to work fairly well, so this will be
officially rolled into LCBO API proper as soon as time allows.

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
opened up to allow 3<sup>rd</sup> parties to write custom metadata.

## A Novel is Written

Today, the original app idea that ignited the motivation to build LCBO API in
the first place has been far surpassed by entire product companies like
[WineAlign](http://winealign.ca) and [Natalie Maclean](http://www.nataliemaclean.com/).
I actually find that really cool.

It shows that ideas can be, and often are, futile. You have to act on them ---
produce with them --- and when you do, what they become isn't something that you
pondered, it's real, it's something you created.

I started with the idea to build a $2.99 iPhone app with my hypothetical pal
Rod, and ended up with a cloud service that leaks money like a sieve and sucks
time like a black hole. A service that is ultimately taken for granted, but then
isn't that the ultimate compliment? To have produced something that is
considered by others a reliable appliance?

An appliance that is used to help students learn, to help enthusiasts locate
specialty drinks, to provide some market insight for small producers, to enable
naive mobile applications on any device. That's something to be proud of, and I
am.

Now you know the story, thanks for listening.

--- Carsten

<footer>
  Please send me an <a href="mailto:carsten@lcboapi.com">email</a> if you have
  any comments, corrections, or suggestions about this post.
</footer>
