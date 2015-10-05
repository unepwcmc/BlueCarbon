window.JST ||= {}

window.JST['tabs'] = _.template("""
  <ul class="tabs">
    <% _.each(workspace.areas, function(area, index) { %>
      <% current_class = (area == workspace.currentArea) ? 'active' : '' %>
      <li data-area-id="<%= index %>" class="<%= current_class %>"><%= area.get('name') %></li>
    <% }); %>

    <% if (workspace.areas.length < 3) { %>
      <li id="add-area"></li>
    <% } %>

  </ul>

  <div id="area">
  </div>
  <script>
    function toggleFullScreen() {
      if (!document.fullscreenElement &&    // alternative standard method
          !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement ) {  // current working methods
        if (document.documentElement.requestFullscreen) {
          document.documentElement.requestFullscreen();
        } else if (document.documentElement.msRequestFullscreen) {
          document.documentElement.msRequestFullscreen();
        } else if (document.documentElement.mozRequestFullScreen) {
          document.documentElement.mozRequestFullScreen();
        } else if (document.documentElement.webkitRequestFullscreen) {
          document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
        }
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        } else if (document.msExitFullscreen) {
          document.msExitFullscreen();
        } else if (document.mozCancelFullScreen) {
          document.mozCancelFullScreen();
        } else if (document.webkitExitFullscreen) {
          document.webkitExitFullscreen();
        }
      }
    }
  </script>

  <div style="position:absolute; bottom: 0; width: 100%; height: 48px; text-align: center; cursor: pointer;" onclick="toggleFullScreen()">TOGGLE FULLSCREEN</div>
""")
