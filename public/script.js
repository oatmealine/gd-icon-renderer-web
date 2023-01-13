'use strict';

// i'm lazy
const $ = document.querySelector.bind(document);

const gamemodes = {
  0: 'cube',
  1: 'ship',
  2: 'ball',
  3: 'ufo',
  4: 'wave',
  5: 'robot',
  6: 'spider'
};

const maxIcons = {
  0: 142,
  1: 51,
  2: 43,
  3: 35,
  4: 35,
  5: 26,
  6: 17
}

function getURL() {
  let params = new URLSearchParams();
  params.set('type', gamemodes[$('#input-type').value]);
  params.set('value', $('#input-value').value);
  params.set('color1', $('#input-color1').value);
  params.set('color2', $('#input-color2').value);
  if ($('#input-glow').checked)
    params.set('glow', 1);

  return '/icon.png?' + params.toString();
}

function updateIcon() {
  const url = getURL();
  const fullURL = window.location.origin + url;
  if ($('#preview').src != fullURL) {
    $('#preview').src = fullURL;
    $('#url').innerText = url;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  updateIcon();

  const fields = [
    $('#input-type'),
    $('#input-value'),
    $('#input-color1'),
    $('#input-color2'),
    $('#input-glow'),
  ];

  fields.forEach(field => {field.addEventListener('change', updateIcon)});

  // spaghetti but oh well

  const updateValueValue = () => {
    $('#label-value').innerText = $('#input-value').value + '/' + maxIcons[$('#input-type').value]
  };
  $('#input-value').addEventListener('input', updateValueValue);
  updateValueValue();

  const updateValueInput = () => {
    $('#input-value').max = maxIcons[$('#input-type').value];
    $('#label-type').innerText = gamemodes[$('#input-type').value];
    updateValueValue();
  };
  $('#input-type').addEventListener('input', updateValueInput);
  updateValueInput();

  const updateColor1Input = () => {
    $('#label-color1').innerText = $('#input-color1').value;
  };
  $('#input-color1').addEventListener('input', updateColor1Input);
  updateColor1Input();

  const updateColor2Input = () => {
    $('#label-color2').innerText = $('#input-color2').value;
  };
  $('#input-color2').addEventListener('input', updateColor2Input);
  updateColor2Input();

  $('#preview').addEventListener('load', () => {
    $('.icon').animate([
      { 'outline': '4px solid var(--accent-color)' },
      { 'outline': '1px solid var(--accent-color)' },
    ], {
      duration: 300,
      iterations: 1,
      fill: 'none'
    });
  });
});