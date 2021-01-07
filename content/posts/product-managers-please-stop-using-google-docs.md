+++
title = "Product Managers: Please Stop Using Google Docs"
slug = "product-managers-please-stop-using-google-docs"
author = "M.Muthukrishna"
date = 2021-01-07T21:11:57+05:30
categories = []
tags = []
draft = false
+++

### Introduction

Product Manager's at Instamojo write PRD in a Google Doc and share it to the software engineers. The Software Engineers can then look into it to understand the requirements and start working on it.

This is a simple setup which just works without any friction. Rite?

This setup fails when Google has an outage (Dec 14 2020, coincidentally my birthday)

![slack-screenshot.jpg](/image/product-managers-please-stop-using-google-docs/slack_screenshot.jpeg)

An index of google docs links should then be maintained elsewhere (probably in an excel sheet, with each sheet corresponding to a team).

Wouldn't it be better if there was just a hyperlink to existing services mentioned in the PRD so that you can also click on it to be redirected to the documenation written about the existing service and understand the gnarly details about said existing service.

It would then be a Knowledge Graph simlar to the one that's available in Britannica Encyclopedia 

There are products available that does exactly this

https://roamresearch.com/

https://www.orgroam.com/

A Better setup would involve each developer setting up orgroam and a script to sync their notes to an S3 Bucket which can then be viewed by others on a static site.

This setup isn't infallible either, AWS S3 Outage would make it inaccessible, but you can always setup a Rpi/NAS in office premises which can serve the static site or have cron jobs to fetch everything that exists in the S3 Bucket and run the static site on your own machine.

To store these notes, you can also use Github, like this
https://github.com/MMuthukrishna/blog

This static site should also be configured so that it has

- Full Text Search
- Search By Author
- Search By Team
- Search By Tags

For the core critical systems which aren't expected to change.
LaTeX can be used and the output PDF can then be made available in the static site.

Why LaTeX?
I'm a fan of Donald Knuth. That's it.

In my opinion this would be a better Knowledge Repo which lets developer learn about different existing systems at a higher level with ease.

I'm a 23 year old software engineer with this knowledge repo wishlist, Industry Veterans that have more experience than my age can probably come up with something better. Feel free to write me an email at muthukrishna.m@instamojo.com or krish789nan@gmail.com to discuss about your knowledge repo setup.
