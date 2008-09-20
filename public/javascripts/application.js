google.load("jquery", "1");

google.setOnLoadCallback( function() {
	jQuery.noConflict();
	// $ is not defined as jQuery here

	var myEditor = new YAHOO.widget.Editor( 'rich-editor', { 
		height: '250px', 
		width: '390px', 
		dompath: true, //Turns on the bar at the bottom 
		animate: true, //Animates the opening, closing and moving of Editor windows 
		handleSubmit: true
	}); 
	myEditor.render();

	( function( $ ) {
		// put stuff here that needs $ to be jQuery

	})( jQuery );

}); // end on load
