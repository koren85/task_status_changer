// /path/to/redmine/plugins/task_status_changer/assets/javascripts/task_status_changer.js
document.addEventListener('DOMContentLoaded', function() {
    var editButton = document.querySelector('a.icon-edit');
    var modalButton = document.getElementById('open-modal-button'); // Обратите внимание, что мы ищем элемент по новому id
    if (editButton && modalButton) {
        // Вставляем кнопку перед кнопкой "Редактировать"
        editButton.insertAdjacentElement('beforebegin', modalButton);
        modalButton.style.display = 'inline-block'; // Отображаем кнопку
    }
});
