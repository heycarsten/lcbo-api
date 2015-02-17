---
title: 'V2 Update, Ontario Craft Brewers Identification'
date: 2015-02-17
author: heycarsten
---

Well, it's been a busy couple of months since my
[last post](/news/whats-next-for-lcbo-api/). In two months, exactly 99 of you
have registered and created API keys, I am humbled and impressed! LCBO API saw
200% more throughput this January compared to last year for a total of 2.3
million requests served, pretty wild for the slowest time of the year!

In other news I've been hard at work on all of the new stuff I have planned for
V2 of LCBO API. Catagories are now a first-class resource as well as producers,
and UPC lookups are now functional.

After I normalized producers it had me thinking about how the official LCBO site
allows people to filter products by VQA designation. I thought it would be nice
to identify products that are produced by
[Ontario Craft Brewers](http://www.ontariocraftbrewers.com/), so I now cross
reference that data with the LCBO product catalog.

I've backported this functionality into V1 so you can start using it immediately.
Products now have a boolean field called `is_ocb` that identifies if the product
is produced by an OCB member. You can also filter on this field with the standard
V1 filtering parameter [`/products?where=is_ocb`](/products?where=is_ocb) or
exclude OCB products by using
[`/products?where_not=is_ocb`](/products?where_not=is_ocb). I'm excited to see
how people integrate this data into their products. It's a simple
addition and one that reflects the direction that LCBO API is taking.

Finally, I'm going to be in Portland, Oregon for the first week of March to attend
[Ember Conf](http://emberconf.com), I realized that this conflicts with
my original release date of March 1<sup>st</sup> for LCBO API V2, so I'm bumping
the date by a week to March 8<sup>th</sup>. I don't want to release V2 when I'm
possibly not available to answer questions and deal with potential issues.

That's it for now, take care everyone!

--- Carsten

---