/**
 * Online Medical System - Common JavaScript Utilities
 */

function confirmLogout() {
    return confirm("Are you sure you want to log out of your medical account?");
}

function togglePassword(inputId, toggleEl) {
    var input = document.getElementById(inputId);
    if (input) {
        input.type = toggleEl.checked ? "text" : "password";
    }
}
