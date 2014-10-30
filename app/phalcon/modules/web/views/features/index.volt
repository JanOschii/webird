
<div class="container">
  <div class="row">
    <div class="col-md-6">
      {{ content() }}
    </div>
  </div>

  <div class="row">
    <div class="col-md-6">
      <h1>{{_('Webird Features')}}</h1>

      <p>
        {{_('This Phalcon and Webpack framework with the following features;')}}
      <p>
    </div>
  </div>

  <div class="row top7">
    <div class="col-md-6">
      <h3>{{_('Frameworks')}}<h3>
      {{ link_to('features/angular', this.translate.gettext('Angular'), 'class':'btn btn-primary') }}
      {{ link_to('features/marionette', this.translate.gettext('Marionette'), 'class':'btn btn-primary') }}
    </div>
  </div>

  <div class="row top7">
    <div class="col-md-6">
      <h3>{{_('Technologies')}}<h3>
      {{ link_to('features/websocket', this.translate.gettext('Ratchet WebSocket'), 'class':'btn btn-primary') }}
    </div>
  </div>
</div>