---
layout: default
label: Todas las películas
---

<style>
.movies-search {
	position: relative;
	margin-bottom: 30px;
}

.movies-search__input {
	width: 100%;
	padding: 12px 15px;
	font-size: 16px;
	border: 1px solid rgba(255, 204, 0, 0.3);
	border-radius: 4px;
	background: rgba(0, 0, 0, 0.3);
	color: #fff;
	box-sizing: border-box;
}

.movies-search__input::placeholder {
	color: rgba(255, 255, 255, 0.5);
}

.movies-search__input:focus {
	outline: none;
	border-color: rgba(255, 204, 0, 0.6);
}

.movies-search__results {
	position: absolute;
	top: 100%;
	left: 0;
	right: 0;
	max-height: 400px;
	overflow-y: auto;
	background: #1a1a1a;
	border: 1px solid rgba(255, 204, 0, 0.3);
	border-top: none;
	border-radius: 0 0 4px 4px;
	display: none;
	z-index: 100;
	list-style: none;
	margin: 0;
	padding: 0;
}

.movies-search__results.active {
	display: block;
}

.movies-search__results li {
	padding: 10px 15px;
	border-bottom: 1px solid rgba(255, 204, 0, 0.1);
}

.movies-search__results li:last-child {
	border-bottom: none;
}

.movies-search__results li a {
	display: block;
}

.movies-search__results li:hover {
	background: rgba(255, 204, 0, 0.1);
}

.movies-search__no-results {
	padding: 15px;
	color: rgba(255, 255, 255, 0.6);
	font-style: italic;
	text-align: center;
}
</style>

{% assign allMovies = site.movies | sort: "name" %}

<div class="movies-search">
	<input 
		type="text" 
		class="movies-search__input" 
		id="movieSearch" 
		placeholder="Buscar por título o director..."
		autocomplete="off"
	>
	<ul class="movies-search__results" id="searchResults"></ul>
</div>

<p>El Festival de Tantarantana ha proyectado un total de <strong>{{ allMovies.size }}</strong> películas a lo largo de su historia.</p>

<ul class="all-movies-list" id="moviesList">
{% for movie in allMovies %}
	<li data-name="{{ movie.name | downcase }}" data-director="{{ movie.director | downcase }}">
		<a href="{{ movie.url }}">{{ movie.name }}</a>, {{ movie.director }} ({{ movie.year }})
	</li>
{% endfor %}
</ul>

<script>
(function() {
	var searchInput = document.getElementById('movieSearch');
	var searchResults = document.getElementById('searchResults');
	var moviesList = document.getElementById('moviesList');
	var allMovies = moviesList.querySelectorAll('li');

	searchInput.addEventListener('input', function() {
		var query = this.value.toLowerCase().trim();
		
		if (query.length < 2) {
			searchResults.classList.remove('active');
			searchResults.innerHTML = '';
			return;
		}

		var matches = [];
		allMovies.forEach(function(movie) {
			var name = movie.getAttribute('data-name');
			var director = movie.getAttribute('data-director');
			if (name.indexOf(query) !== -1 || director.indexOf(query) !== -1) {
				matches.push(movie.innerHTML);
			}
		});

		if (matches.length === 0) {
			searchResults.innerHTML = '<li class="movies-search__no-results">No se encontraron resultados para "' + query + '"</li>';
		} else {
			var resultsHtml = matches.slice(0, 20).map(function(html) {
				return '<li>' + html + '</li>';
			}).join('');
			
			if (matches.length > 20) {
				resultsHtml += '<li class="movies-search__no-results">... y ' + (matches.length - 20) + ' resultados más</li>';
			}
			
			searchResults.innerHTML = resultsHtml;
		}
		
		searchResults.classList.add('active');
	});

	searchInput.addEventListener('focus', function() {
		if (this.value.trim().length >= 2) {
			searchResults.classList.add('active');
		}
	});

	document.addEventListener('click', function(e) {
		if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
			searchResults.classList.remove('active');
		}
	});
})();
</script>
