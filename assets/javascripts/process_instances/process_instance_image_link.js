$(function() {
    $('.popup-bpm-diagram').click(function() {
    	$('#teste-dialog2').dialog({
    		autoOpen: false,
		    minWidth: 700,
		    width: 'auto',
		    height: 'auto',
		    maxHeight: 600,
		    modal: true
    		});
    	$('#teste-dialog2').dialog('open');
    });
});