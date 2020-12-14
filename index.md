---
layout: default
---

{% assign edition2021 = site.editions | where:"object-id", "edition_2021"  | first %}

## La selección oficial 2021

Como dirian en Cannes... *ya está aquí, y es hermosa*. Conoce mes a mes los ciclos del 2021, las motivaciones de sus autores, y qué películas participarán en cada ciclo

<ul class="edition--series">
	{% for editionSerie in edition2021.series %}
		{% assign serie = site.series | where:"object-id", editionSerie.serie-id | first %}
		<li class="edition--serie">
			<a class="edition--serie__link" href="{{ serie.url }}">{{ serie.label }}</a>
		</li>
	{% endfor %}
</ul>

## Conoce al jurado

De aquí y de allá. Amantes del cine clásico, el americano más comercial o el alternativo europeo. Algunos seguidores de las mentes más perturbadas del mundo del cine. Pero todos con un nexo común: su pasión por el cine. 

El Festival de Tantarantana no sería posible sin su maravilloso jurado.

<ul class="edition--members tantarantana--grid">
	{% for editionMember in edition2021.members %}
		{% assign member = site.members | where:"object-id", editionMember.member-id | first %}
		<li class="edition--member tantarantana--grid-item">
			<a class="edition--member__link" href="{{ member.url }}">
				<img class="edition--member__photo" src="/assets/images/members/{{ member.object-id }}.jpg">
				<div class="edition--member__name">
					{{ member.label }}
				</div>				
			</a>
		</li>
	{% endfor %}
</ul>