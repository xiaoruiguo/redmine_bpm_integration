function performUploadClick(node)
{
   document.getElementById('bpm_process_definition_upload').onchange = function() {
     document.upload_form.submit();
   };

   var evt = document.createEvent("MouseEvents");
   evt.initEvent("click", true, false);
   node.dispatchEvent(evt);
}