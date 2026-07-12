---
title: "All Posts"
description: "Browse every article published by StandUp.co.uk."
permalink: /archive/
layout: archive
---

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}
  <section id="{{ year.name }}" class="taxonomy__section">
    <h2 class="archive__subtitle">{{ year.name }}</h2>
    <div class="entries-list">
      {% for post in year.items %}
        {% include archive-single.html type="list" %}
      {% endfor %}
    </div>
  </section>
{% endfor %}
