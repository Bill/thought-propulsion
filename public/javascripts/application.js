google.load("jquery", "1");

google.setOnLoadCallback( function() {
  jQuery.noConflict();
  // $ is not defined as jQuery here

  var Dom = YAHOO.util.Dom, 
      Event = YAHOO.util.Event;
      
  var state = 'off'; 
  
  YAHOO.log('Set state to off..', 'info', 'example'); 

  YAHOO.log('Create the Editor..', 'info', 'example'); 

  var myEditor = new YAHOO.widget.Editor( 'rich-editor', { 
    height: '250px', 
    width: '490px', 
    dompath: true, //Turns on the bar at the bottom 
    animate: true, //Animates the opening, closing and moving of Editor windows
    focusAtStart: true,
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
      /*  { group: 'fontstyle', label: 'Font Name and Size', 
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
      /*    { type: 'separator' }, 
      { type: 'push', label: 'Subscript', value: 'subscript', disabled: true }, 
      { type: 'push', label: 'Superscript', value: 'superscript', disabled: true }, 
      { type: 'separator' }, 
      { type: 'color', label: 'Font Color', value: 'forecolor', disabled: true }, 
      { type: 'color', label: 'Background Color', value: 'backcolor', disabled: true }, 
      */    { type: 'separator' }, 
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

  }); // new YAHOO.widget.Editor(…)

  myEditor.on('toolbarLoaded', function() { 
    var codeConfig = { 
      type: 'push', label: 'Edit HTML Code', value: 'editcode' 
    }; 
    YAHOO.log('Create the (editcode) Button', 'info', 'example'); 
    this.toolbar.addButtonToGroup(codeConfig, 'insertitem'); 

    this.toolbar.on('editcodeClick', function() { 
      var ta = this.get('element'), 
      iframe = this.get('iframe').get('element'); 

      if (state == 'on') { 
        state = 'off'; 
        this.toolbar.set('disabled', false); 
        YAHOO.log('Show the Editor', 'info', 'example'); 
        YAHOO.log('Inject the HTML from the textarea into the editor', 'info', 'example'); 
        this.setEditorHTML(ta.value); 
        if (!this.browser.ie) { 
          this._setDesignMode('on'); 
        } 

        Dom.removeClass(iframe, 'editor-hidden'); 
        Dom.addClass(ta, 'editor-hidden'); 
        this.show(); 
        this._focusWindow(); 
        } else { 
          state = 'on'; 
          YAHOO.log('Show the Code Editor', 'info', 'example'); 
          this.cleanHTML(); 
          YAHOO.log('Save the Editors HTML', 'info', 'example'); 
          Dom.addClass(iframe, 'editor-hidden'); 
          Dom.removeClass(ta, 'editor-hidden'); 
          this.toolbar.set('disabled', true); 
          this.toolbar.getButtonByValue('editcode').set('disabled', false); 
          this.toolbar.selectButton('editcode'); 
          this.dompath.innerHTML = 'Editing HTML Code'; 
          this.hide(); 
        } 
        return false; 
      }, this, true); // this.toolbar.on(…) 

    this.on('cleanHTML', function(ev) { 
      YAHOO.log('cleanHTML callback fired..', 'info', 'example'); 
      this.get('element').value = ev.html; 
      }, this, true); 

    this.on('afterRender', function() { 
      var wrapper = this.get('editor_wrapper'); 
      wrapper.appendChild(this.get('element')); 
      this.setStyle('width', '100%'); 
      this.setStyle('height', '100%'); 
      this.setStyle('visibility', ''); 
      this.setStyle('top', ''); 
      this.setStyle('left', ''); 
      this.setStyle('position', ''); 

      this.addClass('editor-hidden'); 
      }, this, true); 
          
    }, myEditor, true); // myEditor.on(…)
    
    myEditor.render();

  ( function( $ ) {
    // put stuff here that needs $ to be jQuery

    })( jQuery );

}); // end on load
