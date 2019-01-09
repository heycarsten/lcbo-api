---
title: 'LCBO API is now Open Source Software'
date: 2019-01-08
author: heycarsten
---

Hello everyone!

My-oh-my have things changed since my last update a month ago in November!

- Shortly after that post, my lymphoma symptoms started to return and I found out that my [lymphoma](https://en.wikipedia.org/wiki/Diffuse_large_B-cell_lymphoma) is still active, considered aggressively refractory
- **[I released LCBO API as open source software, check it out!](https://github.com/heycarsten/lcbo-api)**
- I will be undergoing immunotherapy ([Yescarta](https://yescarta.com)) as a third-line treatment at [Roswell Park](https://www.roswellpark.org) in [Buffalo, NY](https://en.wikipedia.org/wiki/Buffalo,_New_York)
- My [treatment plan](https://twitter.com/heycarsten/status/1082630102003998721) begins on January 15th, 2019 (the same day I was planning to turn off LCBO API)

The service is currently hosted on [Linode](https://linode.com), has been since 2009. Linode prorates for the month of usage. Since I will be undergoing T-cell harvest on the 15th I won&rsquo;t be turning it off that day. I will however be shutting it down by the end of January.

> Please plan to discontinue using LCBO API on January 15th, but service will continue for a few days after that.

I&rsquo;m also very open to bringing the project back up again! I can no longer personally cover this burden, I can not singlehandedly support and maintain it anymore, however, I&rsquo;d love to be a part of it though, and I have lots of ideas.

My ideal setup for LCBO API would look something like:

- Contanerized - [Amazon ECS](https://aws.amazon.com/ecs/)
- Managed Postgres - [Amazon RDS](https://aws.amazon.com/rds/postgresql/)
- Managed Redis - [Amazon ElastiCache](https://aws.amazon.com/elasticache/redis/)
- Continuous Integration &amp; Deployment - [CircleCI](https://circleci.com/)
- Monitoring - [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/)

I use these technologies and others daily at [work](https://crowdmark.com) with great success. I&rsquo;m not tied to AWS, but I have a lot of experience with the platform. Site reliability, scalability, and security is a big part of my job. If I&rsquo;m involved with the future of lcboapi.com, this is the direction I want to go in. Please note: if you want to host your own instance of LCBO API on your own server, **I fully support you!** I think we could do [something even better](https://github.com/heycarsten/lcbo-api/blob/master/doc/lcboapi-proposed.md) than that, but in the meantime do what you need to do to keep your stuff working!

I have been trying to appeal to corporate sponsors without too much luck so far, but it&rsquo;s still early days. I reached out to [Heroku](https://heroku.com), [Amazon AWS](https://aws.amazon.com), and [Microsoft Azure](https://azure.microsoft.com), this sort of stuff takes time though. _I am positive that something will connect in the coming months._

I&rsquo;ll be sure to keep everyone updated as things develop. If you wish you can follow me and LCBO API on Twitter, I update fairly frequently:

- [@heycarsten](https://twitter.com/heycarsten)
- [@lcboapi](https://twitter.com/lcboapi)

Take care, everyone!

--- Carsten

---