google.load("jquery", "1");

google.setOnLoadCallback( function() {
	jQuery.noConflict();
	// $ is not defined as jQuery here

	var myEditor = new YAHOO.widget.Editor( 'rich-editor', { 
		height: '250px', 
		width: '490px', 
		dompath: true, //Turns on the bar at the bottom 
		animate: true, //Animates the opening, closing and moving of Editor windows 
		handleSubmit: true,
		markup: 'xhtml',
		toolbar: {collapse: true, 
			titlebar: 'Editing Your Twip', 
			draggable: false, 
			buttonType: 'advanced', 
			buttons: [ 
			{ type: 'separator' }, 
			{ group: 'insertitem', label: 'Insert Item', 
			buttons: [ 
			{ type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true }, 
			{ type: 'push', label: 'Insert Image', value: 'insertimage' } 
			] 
			},
		/*	{ group: 'fontstyle', label: 'Font Name and Size', 
					buttons: [ 
					{ type: 'select', label: 'Arial', value: 'fontname', disabled: true, 
					menu: [ 
					{ text: 'Arial', checked: true }, 
					{ text: 'Arial Black' }, 
					{ text: 'Comic Sans MS' }, 
					{ text: 'Courier New' }, 
					{ text: 'Lucida Console' }, 
					{ text: 'Tahoma' }, 
					{ text: 'Times New Roman' }, 
					{ text: 'Trebuchet MS' }, 
					{ text: 'Verdana' } 
					] 
				}, 
				{ type: 'spin', label: '13', value: 'fontsize', range: [ 9, 75 ], disabled: true } 
				] 
				},*/
		{ type: 'separator' },
		{ group: 'textstyle', label: 'Font Style', 
		buttons: [ 
		{ type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' }, 
		{ type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' }, 
		{ type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' }, 
/*		{ type: 'separator' }, 
		{ type: 'push', label: 'Subscript', value: 'subscript', disabled: true }, 
		{ type: 'push', label: 'Superscript', value: 'superscript', disabled: true }, 
		{ type: 'separator' }, 
		{ type: 'color', label: 'Font Color', value: 'forecolor', disabled: true }, 
		{ type: 'color', label: 'Background Color', value: 'backcolor', disabled: true }, 
*/		{ type: 'separator' }, 
		{ type: 'push', label: 'Remove Formatting', value: 'removeformat', disabled: true }, 
		{ type: 'push', label: 'Show/Hide Hidden Elements', value: 'hiddenelements' } 
		] 
		},
		{ type: 'separator' }, 
		{ group: 'parastyle', label: 'Paragraph Style', 
		buttons: [ 
		{ type: 'select', label: 'Normal', value: 'heading', disabled: true, 
		menu: [ 
		{ text: 'Normal', value: 'none', checked: true }, 
		{ text: 'Heading 2', value: 'h2' }, 
		{ text: 'Heading 3', value: 'h3' }, 
		] 
		} 
		] 
		}, 
		 
		{ type: 'separator' }, 
		{ group: 'alignment', label: 'Alignment', 
		buttons: [ 
		{ type: 'push', label: 'Align Left CTRL + SHIFT + [', value: 'justifyleft' }, 
		{ type: 'push', label: 'Align Center CTRL + SHIFT + |', value: 'justifycenter' }, 
		{ type: 'push', label: 'Align Right CTRL + SHIFT + ]', value: 'justifyright' }, 
		{ type: 'push', label: 'Justify', value: 'justifyfull' } 
		] 
		}, 
		{ type: 'separator' }, 
		{ group: 'indentlist', label: 'Indenting and Lists', 
		buttons: [ 
		{ type: 'push', label: 'Indent', value: 'indent', disabled: true }, 
		{ type: 'push', label: 'Outdent', value: 'outdent', disabled: true }, 
		{ type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' }, 
		{ type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' } 
		] 
		}
		 
		]}
		
	}); 
	myEditor.render();

	( function( $ ) {
		// put stuff here that needs $ to be jQuery

	})( jQuery );

}); // end on load
