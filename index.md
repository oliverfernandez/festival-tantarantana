---
layout: default
label: IX Edición
---

{% assign edition2022 = site.editions | where:"object-id", "edition_2022"  | first %}

## La selección oficial del 2022...

...es un misterio. Este año practicaremos la emoción y quizás sea hasta ahora el año más diferente. Abrid vuestras mentes y dejaos llevar por esta aventura incierta. Así que... ¡pasajeros al tren!

<ul class="edition--series">
	{% for editionSerie in edition2022.series %}
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
	{% for editionMember in edition2022.members %}
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

## Anteriormente en Tantarantana...

Conoce todo lo que ha dado de si el festival echando un vistazo a ediciones pasadas

<div class="editions--history">
	{% include edition_menu.html %}
</div>