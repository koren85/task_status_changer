// /path/to/redmine/plugins/task_status_changer/assets/javascripts/task_status_changer.js

document.addEventListener('DOMContentLoaded', function() {
    var ruleIndex = document.querySelectorAll('.status-rule').length;

    window.addRule = function() {
        var rulesContainer = document.getElementById('status-transition-rules');
        var newRuleHTML = `
      <div class="status-rule" data-index="${ruleIndex}">
        <p>
          <label for="settings_status_transition_rules_${ruleIndex}_current_status">Current Status</label>
          <select name="settings[status_transition_rules][${ruleIndex}][current_status]" id="settings_status_transition_rules_${ruleIndex}_current_status">
            ${getStatusOptions()}
          </select>
          <label for="settings_status_transition_rules_${ruleIndex}_new_status">New Status</label>
          <select name="settings[status_transition_rules][${ruleIndex}][new_status]" id="settings_status_transition_rules_${ruleIndex}_new_status">
            ${getStatusOptions()}
          </select>
          <button type="button" class="remove-rule-button" onclick="removeRule(this)">Remove</button>
        </p>
      </div>
    `;
        rulesContainer.insertAdjacentHTML('beforeend', newRuleHTML);
        ruleIndex++;
    };

    window.removeRule = function(button) {
        var ruleElement = button.closest('.status-rule');
        ruleElement.remove();
    };

    function getStatusOptions() {
        var statuses = JSON.parse(document.getElementById('statuses-data').innerText);
        return statuses.map(function(status) {
            return `<option value="${status.id}">${status.name}</option>`;
        }).join('');
    }
});
