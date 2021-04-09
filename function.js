var search = document.getElementById('search');
var button = document.getElementById('button');
var input = document.getElementById('input');
 
function loading() {
 search.classList.add('loading');
 
 setTimeout(function() {
 search.classList.remove('loading');
 }, 1500);
}
 
button.addEventListener('click', loading);
 
input.addEventListener('keydown', function() {
 if(event.keyCode == 13) loading();
});

"use strict";
var underlineMenuItems = document.querySelectorAll("ul li");
underlineMenuItems[0].classList.add("active");
underlineMenuItems.forEach(function (item) {
    item.addEventListener("click", function () {
        underlineMenuItems.forEach(function (item) { return item.classList.remove("active"); });
        item.classList.add("active");
    });
});