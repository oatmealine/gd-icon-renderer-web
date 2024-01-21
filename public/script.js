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
  6: 'spider',
  7: 'swing',
  8: 'jetpack',
};

const maxIcons = {
  0: 484,
  1: 169,
  2: 118,
  3: 149,
  4: 96,
  5: 68,
  6: 69,
  7: 43,
  8: 5,
}

const maxColor = 107

function getURL() {
  let params = new URLSearchParams();
  params.set('type', gamemodes[$('#input-type').value]);
  params.set('value', $('#input-value').value);
  params.set('color1', $('#input-color1').value);
  params.set('color2', $('#input-color2').value);
  const col3 = $('#input-color3').value;
  if (col3 !== '-1') params.set('color3', col3);
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
    $('#input-color3'),
    $('#input-glow'),
  ];

  $('#input-type').max = Object.keys(gamemodes).length - 1;
  $('#input-color1').max = maxColor - 1;
  $('#input-color2').max = maxColor - 1;
  $('#input-color3').max = maxColor - 1;

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

  const updateColor3Input = () => {
    const col3 = $('#input-color3').value;
    $('#label-color3').innerText = col3 === '-1' ? 'None' : col3;
  };
  $('#input-color3').addEventListener('input', updateColor3Input);
  updateColor3Input();

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