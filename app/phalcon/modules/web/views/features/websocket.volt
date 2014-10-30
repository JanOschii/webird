<!DOCTYPE html>
<html>
<head>
  <title>{{_('Webird WebSocket Technology Demo')}}</title>
{{ partial('head_init') }}
  {{ stylesheet_link(['href': path~'css/style_bootstrap.css']) }}
  {{ javascript_include(['src': path~'js/init_complex.js']) }}
  {{ javascript_include(['src': path~'js/websocket.js']) }}
</head>
<body>
  <div class="container">
    <div class="row">
      <div class="col-md-6">
        <h1>{{_('Websocket Feature')}}</h1>
        <p>
          {{_('Phalcon, Webpack and Ratchet integration example:')}}
        <p>
      </div>
    </div>

    <div class="row top7">
      <div id="websocket_console" class="col-md-6">
      </div>
    </div>
  </div>
</body>