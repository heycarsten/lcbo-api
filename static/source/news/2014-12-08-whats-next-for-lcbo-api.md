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
started my iPhone app! Just bulding the API, maintaining the crawler, adding
useful features and responding to emails was keeping me very busy in my
free-time.

## Surprises Abound

I honestly never thought LCBO API would become as popular as it has. Last month
(November) it served **1.4 million requests** and over **100** dataset
downloads. LCBO API was a little side project that I put way too much time into
because I'm an obsessive person. I thought it would help me maybe get a job,
and ultimately some people might use it to build the sorts of apps that I wanted
to build. But I never, ever would have foresaw what has actually happend over
the past six years.

## LCBO API Today

So it's interesting, the data is almost viewed as a birthright, not as a service
that I've invested a lot of my personal time and money into. I do it because I
enjoy it, but I also have a family and numerous other commitments. It can be
hard.

## LCBO API V2

### JSON API compliance

This probably doesn't mean much to most developers, but it means a lot to me.
The JSON structure of the V1 API is just what worked, smart people have put a
lot of effort into this realm over the last few years and it makes consuming
the API a lot easier.

### UPC lookups

YES, FINALLY. I know. Getting the data reliably and for at least 70% of the
catalog was a tricky one, but it's happening.

### Categories and Regions

For completness sake and to make it easier to implement discovery / browsing
apps.

### Store(s) with Product(s)

This is a doozie, I've been asked for this feature quite a few times. I've even
been told how easy it is to implement, it's not. I do think that to have a
great "shopping-list" functionality in an app, it's a worthwhile ocean to boil,
so it's going to happen.

### Historical metrics

Aggregate metrics such as turnover rate, and.

### Intelligent crawler

I spiked out a few months ago a new style of crawler that actually analyzes
various respected blogs and news sites for LCBO product numbers, it then uses
those to perform priority crawls of those products. This will be officially
rolled into the project.

## Problems

It was in the summer of 2010 that I first started realizing maybe open and free
wasn't the greatest idea I'd ever had. Usage of the API was increasing rapidly,
I was getting cross emails on a weekly basis about a store name being incorrect,
inventory levels not being updated on a perfect consistency, why didn't the API
have x feature, or y feature, it's not hard to implement so why isn't it in
there?

This stuff wore me down, really wore me down. I became very bitter about the
project, but for all the 