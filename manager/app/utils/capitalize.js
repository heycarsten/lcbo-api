export default function(str) {
  if (!str) {
    return '';
  }

  return str.dasherize().split('-').map(function(word) {
    return word.capitalize();
  }).join(' ');
}
