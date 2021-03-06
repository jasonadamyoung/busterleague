jQuery ->
  $('#dynamicsearch').searchbox({
    url: '/draft/players/search',
    param: 'q',
    dom_id: '#search-results',
    delay: 250,
    loading_css: '#spinner'
  })