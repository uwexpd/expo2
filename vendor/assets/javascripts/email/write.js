$(function() {
	$('#email_template_id').on('change', function(){
	    let email_template_id = $(this).val();
	    // alert(email_template_id);
			// ajax request
		    $.ajax({
		      url: "apply_template",
		      method: "GET",
		      data: {
		        email_template_id: email_template_id
		      },
		      complete: function () {
	 				if (email_template_id){
	 					$('#update_email_template_form').show(600);
	 				}else{
	 					$('#update_email_template_form').hide(600);
	 				}
	 			}
		    });
	})

	$('#create_email_template').on('change', function(){
		if(this.checked) {
			$('#new_email_template_name').show()
		}else{
				$('#new_email_template_name').hide()
		} 
	})

	$('#preview_sample_button').on('click', function(e){
	  e.preventDefault(); // Prevent the default link behavior
	   // Serialize the form data
	  let formData = $('#email_write_form').serialize();

	  // Submit the form using AJAX
	  $.ajax({
	    type: 'POST',
	    url: $(this).attr('href'),
	    data: formData,
	    dataType: 'script',
	    success: function(data) {
	      // console.log('Success:', data);
	    },
	    error: function(xhr, status, error) {
	      console.error('Error:', error);
	    }
	  });
	})

	$('a.use_as_sample_link').on('click', function(e){
	  e.preventDefault(); // Prevent the default link behavior
	  let formData = $('#email_write_form').serialize();

	  // Submit the form using AJAX
	  $.ajax({
	    type: 'POST',
	    url: $(this).attr('href'),
	    data: formData,
	    dataType: 'script',
	    success: function(data) {
	      // console.log('Success:', data);
	    },
	    error: function(xhr, status, error) {
	      console.error('Error:', error);
	    }
	  });
	})
});