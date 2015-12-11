$(function() {
  $('.popup_bpm_diagram').click(function() {
  	var image = $('<img />').attr('src', $(this).data('url')).load(function() {
      $("#diagram_loader").html($(this));
	    $('#diagram_loader').dialog({
	      autoOpen: true,
	      minWidth: 700,
	      width: 'auto',
	      height: 'auto',
	      maxHeight: 600,
	      modal: true
	    }).dialog('open');
    });
  });
});
