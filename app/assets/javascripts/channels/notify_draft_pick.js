(function() {
  App.cable.subscriptions.create('NotifyDraftPickChannel', {
    connected: function() {
    },
    disconnected: function() {
    },
    received: function(data) {
      var currentPickedCount = data.picked_count;
      var browserPickedCount= Cookies.get('picked_count');
      console.log('got data!')

      if(browserPickedCount) {
        if(currentPickedCount != browserPickedCount) {
          console.log('counts not equal')
          Cookies.set('picked_count', currentPickedCount);
          window.location.replace(window.location.href);
        }
      }else {
        Cookies.set('picked_count', currentPickedCount);
      }
    }
  });

}).call(this);