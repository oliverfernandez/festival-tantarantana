---
layout: default
label: X Edición
---

{% assign edition2023 = site.editions | where:"object-id", "edition_2023"  | first %}

## La selección oficial del 2023

Frank Capra decía que el cine era como una enfermedad: "Cuando infecta tu sange, se apodera de tu cuerpo hasta llegar a tu mente y, al igual que la heroína, el antídoto para el cine es más cine".

Espero estar a la altura de este festival que tanto queremos! Este año habrán muchos cambios pero los recibo con muchísima ilusión y estoy seguro que funcionarán y enriquecerán el festival!

Que sea un año lleno de buen cine, de grandes críticas y que podamos juntarnos muchas veces viendo películas!

Y como aquél maravilloso 28 de Diciembre de 1895 se citó en un Café francés: "Que la lumière soit!"!

<ul class="edition--series">
	{% for editionSerie in edition2023.series %}
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
	{% for editionMember in edition2023.members %}
		{% assign member = site.members | where:"object-id", editionMember.member-id | first %}
		<li class="edition--member tantarantana--grid-item">
			<a class="edition--member__link" href="{{ member.url }}">
				<img class="edition--member__photo" src="/assets/images/members/{{ member.object-id }}.jpg">
				<div class="edition--member__name">
					{{ member.label }}
				</div>				
			</a>
			{% if edition2023.presidents-id contains member.object-id %}
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