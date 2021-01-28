const fetch = require('node-fetch');
const { JSDOM } = require('jsdom');

const filmaffinityUrl = process.argv[2];

const tantarantanaMovie = {};


fetch(filmaffinityUrl)
	.then(response => response.text())
	.then(text => new JSDOM(text))
	.then(({ window }) => {
		tantarantanaMovie = {
			
		}
	});