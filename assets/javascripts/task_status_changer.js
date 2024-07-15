// /path/to/redmine/plugins/task_status_changer/assets/javascripts/task_status_changer.js
document.addEventListener('DOMContentLoaded', function() {
    var editButton = document.querySelector('a.icon-edit');
    if (editButton) {
        var changeStatusButton = document.getElementById('change-status-button');
        if (changeStatusButton) {
            editButton.insertAdjacentElement('beforebegin', changeStatusButton);
            changeStatusButton.style.display = 'inline-block';
        }
    }
});
