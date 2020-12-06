---
layout: default
---

## La selección oficial 2021

Como dirian en Cannes... *ya está aquí, y es hermosa*. Conoce mes a mes los ciclos del 2021, las motivaciones de sus autores, y qué películas participarán en cada ciclo

{% assign edition2021 = site.editions | where:"object-id", "edition_2021"  | first %}

<ul class="edition">
	{% for editionSerie in edition2021.series %}
		{% assign serie = site.series | where:"object-id", editionSerie.serie-id | first %}
		<li class="edition--serie">
			<a class="edition--serie__link" href="{{ serie.url }}">{{ serie.label }}</a>
		</li>
	{% endfor %}
</ul>

## Conoce al jurado

<ul class="members">
	{% for editionSerie in edition2021.series %}
		{% assign serie = site.series | where:"object-id", editionSerie.serie-id | first %}
		<li class="edition--serie">
			<a class="edition--serie__link" href="{{ serie.url }}">{{ serie.label }}</a>
		</li>
	{% endfor %}
</ul>