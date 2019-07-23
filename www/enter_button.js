$(document).keyup(function(event) {
    if ($("#lengthInput").is(":focus") && (event.key == "Enter")) {
        $("#go").click();
        $("#lengthInput").select();
    }
});
