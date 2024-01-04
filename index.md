---
layout: default
label: XI Edición
---

{% assign edition2024 = site.editions | where:"object-id", "edition_2024"  | first %}

## 2024 es un año especial para el Festival de cine Tantarantana
<img src="/assets/images/2024.JPG">

¡Tantarantana cumple 10 años y hemos decidido celebrarlo por todo lo alto! Porque el cine no es sólo descubrimiento, entretenimiento y sorpresa… también es recuerdo, nostalgia, aprendizaje, experiencia…

En esta edición veremos algunos de nuestros títulos favoritos, incluyendo las finalistas de las primeras nueve ediciones, pero también algunas de las películas que más marcaron nuestra infancia, aquellas que no podemos evitar ver una y otra vez, y otras que, por mucho que el tiempo pase y no hayamos vuelto a revisionar, jamás podremos olvidar. Porque el tiempo puede hacernos ver las películas con otros ojos, cambiar nuestras gustos y opiniones, hacernos experimentar diferentes sensaciones como parte del proceso de crecimiento y maduraración, pero jamás borrará nuestro amor incondicional por el cine…

<ul class="edition--series">
	{% for editionSerie in edition2024.series %}
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
	{% for editionMember in edition2024.members %}
		{% assign member = site.members | where:"object-id", editionMember.member-id | first %}
		<li class="edition--member tantarantana--grid-item">
			<a class="edition--member__link" href="{{ member.url }}">
				<img class="edition--member__photo" src="/assets/images/members/{{ member.object-id }}.jpg">
				<div class="edition--member__name">
					{{ member.label }}
				</div>				
			</a>
			{% if edition2024.presidents-id contains member.object-id %}
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