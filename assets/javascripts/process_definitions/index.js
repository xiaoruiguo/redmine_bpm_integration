function performUploadClick(node)
{
   document.getElementById('bpm_process_definition_upload').onchange = function() {
     document.upload_form.submit();
   };

   var evt = document.createEvent("MouseEvents");
   evt.initEvent("click", true, false);
   node.dispatchEvent(evt);
}

$(function() {
  $('.popup_bpm_diagram').click(function() {
    if ($(this).data('url')) {
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
    }
  });
});
