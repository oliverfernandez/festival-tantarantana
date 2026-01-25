---
layout: default
label: XII Edición
---

{% assign edition2026 = site.editions | where:"object-id", "edition_2026"  | first %}

## La selección oficial del 2026

<ul class="edition--series">
	{% for editionSerie in edition2026.series %}
		{% assign serie = site.series | where:"object-id", editionSerie.serie-id | first %}
		<li class="edition--serie">
			<a class="edition--serie__link" href="{{ serie.url }}">{{ serie.label }}</a>
		</li>
	{% endfor %}
</ul>

## Conoce al jurado

De aquí y de allá. Amantes del cine clásico, el americano más comercial o el alternativo europeo. Algunos seguidores de las mentes más perturbadas del mundo del cine. Pero todos con un nexo común: su pasión por el cine. 

El **Festival de Tantarantana** no sería posible sin su maravilloso jurado.

<ul class="edition--members tantarantana--grid">
	{% for editionMember in edition2026.members %}
		{% assign member = site.members | where:"object-id", editionMember.member-id | first %}
		<li class="edition--member tantarantana--grid-item">
			<a class="edition--member__link" href="{{ member.url }}">
				<img class="edition--member__photo" src="/assets/images/members/{{ member.object-id }}.jpg">
				<div class="edition--member__name">
					{{ member.label }}
				</div>				
			</a>
			{% if edition2026.presidents-id contains member.object-id %}
				<img class="edition--members__president_badge" src="/assets/images/badge.png" title="President">
			{% endif %}
		</li>
	{% endfor %}
</ul>

## Anteriormente en Tantarantana...

Conoce todo lo que ha dado de si el festival echando un vistazo a ediciones pasadas

<div class="editions--history">
	{% include edition_menu.html %}
</div>
