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
  $('.bpm_diagram').click(function() {
    $("#diagram_loader").html('<img src="' + $(this).data('url') + '" />');
      $('#diagram_loader').dialog({
        autoOpen: false,
        minWidth: 700,
        width: 'auto',
        height: 'auto',
        maxHeight: 600,
        modal: true
      }).dialog('open');
  });
});