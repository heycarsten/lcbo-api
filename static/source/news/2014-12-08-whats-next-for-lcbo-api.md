---
title: 'What&rsquo;s next for LCBO API'
date: 2014-12-08
author: heycarsten
---

<div class="center">
  <img src="/assets/images/news/500-best-value-wines-2009.jpg" width="190">
</div>

This December marks **six** years since I picked up Rod Phillips&rsquo; book
[The 500 Best-Value Wines in the LCBO](http://www.amazon.ca/The-Best-Value-Wines-LCBO-2009/dp/155285938X)
and thought, "Wouldn't it be cool if I could use my phone to see a list of the
wines in this book at the store I'm standing in?"

I wanted to build it, but how? --- I'd need to talk to Rod, I'd need to
start learning about iPhone development --- but before I did anything, I'd need
some way to easily access the LCBO store, product, and inventory data that the
app would rely on for the basis of it's functionality.

## The Early Days

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
invested nearly 600 hours of my time into the project, and I still hadn't
started that iPhone app! Just bulding the API, maintaining the crawler, adding
useful features and responding to emails was keeping me very busy in my
free-time.

## The Good Days

I honestly never thought LCBO API would become as popular as it has. Last month
(November) it served **1.4 million requests** and over **100** dataset
downloads. LCBO API was a little side project that I put way too much time into
because I'm an obsessive person. I thought it would help me maybe get a job,
and ultimately some people might use it to build the sorts of apps that I wanted
to build. But I never, ever would have foresaw what has actually happend over
the past six years.

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
learn about REST and JSON and how to consume an API in whatever runtime they're
being taught. Beer and wine loves with an interest in programming have hacked
together scripts to alert them when their favorite drink becomes available at
a nearby store. Independent brewers and winemankers have analyized and
identified how their products are doing and where the most active markets
are to get their product in the hands of people who want them.

I love getting these emails, they just make my day! One of the most jaw-dropping
message I ever received was from a statistician at Harvard who was using the
historical datasets as fixtures for testing different alogrythms in their
research. It was really humbling and it drove home the fact that LCBO API
isn't just some liquor store data, it also represents time and place for an
entire retail sector in a large market.

I've had the pleasure of being introduced to all these incredible people doing
such great things, without LCBO API, I doubt any of these experiences would have
ever happened. As much as I'd like to end it there, in order to tell the whole
story, I also have to discuss some of the not-so-enjoyable experiences I've had
running LCBO API.

## The Bad Days

Every now and then an eger opportunist will reach out to me and pitch how I
could work with them to gatekeep and resell the crawled inventory data to small
businesses in a report format. Presenting it to them like some sort of golden
carrot and charging dearly for a bite. Game-changers like this in any field are
what stifle innovation and cause even more hardship to people and businesses who
are already struggling enough to produce and survive in our market. Plus, the
LCBO already officially provides this through their
[Sale of Data](http://www.lcbo.com/webapp/wcs/stores/servlet/en/sod/)
service.

Perhaps the most upsetting part is that some of these people have been active
members of the indy beer and wine community in Ontario, seen as peers by the
very people they are preying on. It's disturbing, unbeliveably self-serving, and
creates a toxic environment. The thought that LCBO API might be used to fuel
schemes like this just breaks my heart. <i class="fa fa-frown-o"></i>

In the past, particularly the spring of 2012, changes were being made to
LCBO.com on a fairly routine basis. There were a couple occasions where I was
not able to update the crawler for days on end, and the data became stale. It
was a very frustrating time for me as I had no power to fix things even though
I was desperate to do so. During this period I was sent scolding emails from two
different CTOs, berating me for the lapse and how it was making them "look like
fools" to their paying customers. **Paying customers**!

These events left me shakingly angry, and feeling powerless over the project.
This is the dark side of running LCBO API, but you know what? The good days far
outnumber the bad ones, and it's those good days, and emails, and stories that
fuel my passion for working on LCBO API. All of that said, I know that I can do
better. <i class="fa fa-smile-o"></i>

## Moving Forward

This leads me to **THE BIGGEST MISTAKE I HAVE EVER MADE**: making LCBO API
so darn casual and anonymous. This has attached to the project a stigma of
grassroots hackery, which I love, but it doesn't tell the true story. LCBO API
isn't a hybrid Wordpress installation, built in a Redbull-fuled weekend and
left to run its course. LCBO API is a real software platform and I give it the
utmost attention and care. I want to make sure that this is obvious going
forward, so I'm making some changes.

### Shiny New Design

The look and feel of the old site was really bothering me, I cobbled it together
in a few hours back in 2009, it didn't reflect the project very well and I've
wanted to update it for years. So I finally did, yay! I'm hoping the new look
and feel will reinforce what LCBO API actually is, and will continue to grow
with the project.

### No More _Unlimited_ Anonymous Access

Anonyminity is awesome, and I believe in its power passionately, but it's also
taking away from the potential of the project. For the sake of my sanity, and to
provide a better service, I need to have an understanding of who is using
LCBO API, for what and where, because of this I am introducing the concept of
API access keys to LCBO API.

Anonymous access will remain but it will be rate-limited, this means that you
won't need an access key for playing around or learning, which is really
important to me. This also means that existing mobile and JavaScript apps will
continue to work as they do today. If you're using LCBO API for anything beyond
that, you'll want a free Access Key. You'll also gain some insight with your
key, I plan to build out the management panel and provide some useful features
like usage stats and analytics.

<p class="warning">
  As of March 1<sup>st</sup>, 2015 anonymous API access will be
  rate-limited.
</p>

### If you're making money with LCBO API, please support it

I don't want to sound like Jimmy Wales here, but outside of simply charging for
API access on a subscription model, I'm hard pressed to come up with a way to
financially sustain the project. The hard costs aren't crazy, right now LCBO
API consists of a load balancer, app server, worker server, and database server,
it averages about $100/month in hosting costs plus another $50/month for AWS,
monitoring, and backups.

Financial support isn't for the hosting costs, it's for my time. Maintaining the
crawlers and ensuring updates happen daily and that the data is consistent and
of high quality. Ensuring performance remains exceptional and dealing with
bottlenecks when they occurr. Developing new features to provide value that can
benefit everyone. Without financial support, I have to rely on other work to pay
the bills, this isn't a problem, but it means I have less time available to work
on LCBO API.

I really don't enjoy talking about this stuff, and I wish I was able to figure
it out on my own without needing to whine about it here, but now it's out there
and it's very clear. There are no secrets, **LCBO API costs about $150/month to
run, and it generates $0/month in income**, every dollar of support helps.

## LCBO API V2

Now for the exciting stuff, as I said before LCBO API was introduced in 2009 and
the visible API hasn't really changed since that time. _UNTIL NOW_

### HTTPS & CORS

I've actually backported these features into V1 and they're active and
available. Check out the [documentation](/docs/v1#getting-started) for more
details.

### UPC Support

YES, FINALLY. I know. You'll be able to look up products via barcode.

### JSON API Compliance

This probably doesn't mean much to most people, but it means a lot to me.
The JSON structure of the V1 API was born out of what just what worked at the
time. Smart people have put a lot of effort into this realm over the last few
years and it makes consuming the API a lot easier when its structure complies
with an open standard.

### Category and Producer APIs

For completness sake and to make it easier to implement discovery / browsing
apps, I'll be normalizing category and producer data and providing API
endpoints.

### Store(s) with Product(s)

This is a doozie, I've been asked for this feature quite a few times. I've even
been told how easy it is to implement, _it's not_. That said, it's required
functionality if you want to build something like a great shopping-list feature.
It's a worthwhile ocean to boil, and I'm excited to bring it to LCBO API.

### Historical Metrics

Aggregate metrics such as turnover rate and confidence in inventories. This will
allow developers to alert users if it looks like a product might not actually
be available. Eg: consumption increases on Thursday, and spikes on Saturday. If
a product is selling consistently throughout the week, and there are only a few
left on Saturday morning, it's very likely by Saturday evening they won't be
available anymore. Conversely, some products are stocked in very low levels and
have very low turnover, this also has to be considered as to avoid
false-positives.

### Intelligent Crawler

A few months ago I spiked out an accessory crawler that actually analyzes
various respected blogs and news sites for LCBO product numbers. The plan was to
then use that information to perform priority crawling for pricing and inventory
data of those products. It seems to work fairly well, so this will be
officially rolled into LCBO API proper as soon as time allows.

### Webhooks

Now that LCBO API has the concept of accounts and Access Keys adding support
for webhooks is totally doable. You'll be able to register against numerous
events like when products are added or removed, when prices change, and product
availability notices, not to mention when new datasets become available.

### Meta API

I want to work with sites like [Untappd](https://untappd.com) to incorporate
ratings and other useful data so that it can be used in queries. Don't worry,
this data would only become visible if you ask for it in requests, imagine
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

This would enable all sorts of cool uses and possibilites!
