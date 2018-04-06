shinyjs.init = function(){
  $('#nav li a[data-value="Cluster"]').hide();
  $('#nav li a[data-value="scamnull"]').hide();
  $('#nav li a[data-value="scamDT"]').hide();
  $('#nav li a[data-value="All Addresses"]').hide();
  $('#nav li a[data-value="Transactions"]').hide();
  $('#nav li a[data-value="Graph"]').hide();
  $('#nav li a[data-value="Summary"]').hide();
  $('#nav li a[data-value="About"]').tab('show');
}

shinyjs.showTabSelect = function(tabName){
  $('#nav li a[data-value=\'' + tabName + '\']').show();
  $('#nav li a[data-value=\'' + tabName + '\']').tab('show');
}

shinyjs.showTab = function(tabName){
  $('#nav li a[data-value=\'' + tabName + '\']').show();
}

shinyjs.hideTab = function(tabName){
  $('#nav li a[data-value=\'' + tabName + '\']').hide();
}
