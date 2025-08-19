---
title: "Edinburgh Fringe 2025 – Comedy Coverage"
permalink: /edinburgh/
layout: single
---

![Comedian at an Edinburgh club](/assets/images/edinburgh.png)

All our coverage of the 2025 Edinburgh Fringe Festival.

<ul>
  {% for post in site.categories.edinburgh %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a><br>
      <span class="post-date">{{ post.date | date: "%-d %B %Y" }}</span>
    </li>
  {% endfor %}
</ul>

