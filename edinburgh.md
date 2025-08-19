---
title: "Edinburgh Fringe 2025 – Comedy Coverage"
permalink: /edinburgh/
layout: single
---

![Comedian at an Edinburgh club](/assets/images/edinburgh.png)

<ul>
  {% for post in site.categories.edinburgh %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      <span class="post-date">{{ post.date | date: "%-d %B %Y" }}</span>
    </li>
  {% endfor %}
</ul>

