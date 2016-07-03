//= require_tree .

function selectAll() {
  checkboxes = document.getElementsByClassName('checkboxes');
  for (var i = checkboxes.length - 1; i >= 0; i--) {
    checkboxes[i].checked = true;
  }
}
