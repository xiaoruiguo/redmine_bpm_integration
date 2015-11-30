$(function() {
    $('.popup_bpm_diagram').click(function() {
    	$('#diagram_loader').dialog({
    		autoOpen: false,
		    minWidth: 700,
		    width: 'auto',
		    height: 'auto',
		    maxHeight: 600,
		    modal: true
    		});
    	$('#diagram_loader').dialog('open');
    });
});