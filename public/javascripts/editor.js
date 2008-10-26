addLoad( function() {
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
    css: '',
    extracss: '',
    hiddencss: '',
    html: '<html><head><title>{TITLE}</title><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><base href="' + location.protocol + '//' + location.host + '"><style>{CSS}</style><style>{HIDDEN_CSS}</style><style>{EXTRA_CSS}</style></head><body class="twip" onload="document.body._rteLoaded = true;">{CONTENT}</body></html>',
    toolbar: {

      collapse: true, 
      titlebar: 'Editing Your Twip', 
      draggable: false, 
      buttonType: 'advanced', 
      
      buttons: [
        { group: 'insertitem', label: 'Insert',
          buttons: [ 
            { type: 'push', label: 'HTML Link CTRL + SHIFT + L', value: 'createlink', disabled: true}, 
            { type: 'push', label: 'Insert Image', value: 'insertimage'}
          ] 
        },

        { type: 'separator' },

        { group: 'textstyle', label: 'Style Font',
          buttons: [ 
            { type: 'push', label: 'Bold CTRL + SHIFT + B', value: 'bold' }, 
            { type: 'push', label: 'Italic CTRL + SHIFT + I', value: 'italic' }, 
            { type: 'push', label: 'Underline CTRL + SHIFT + U', value: 'underline' }, 

            { type: 'separator' },

            { type: 'push', label: 'Remove Formatting', value: 'removeformat', disabled: true },

            { type: 'push', label: 'Show/Hide Hidden Elements', value: 'hiddenelements' }
          ] 
        },

        { type: 'separator' }, 

        { group: 'parastyle', label: 'Style Paragraph',
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

        { group: 'alignment', label: 'Align',
          buttons: [
            { type: 'push', label: 'Align Left CTRL + SHIFT + [', value: 'justifyleft' }, 
            { type: 'push', label: 'Align Center CTRL + SHIFT + |', value: 'justifycenter' }, 
            { type: 'push', label: 'Align Right CTRL + SHIFT + ]', value: 'justifyright' }, 
            { type: 'push', label: 'Justify', value: 'justifyfull' }
          ] 
        },

        { type: 'separator' },

        { group: 'indentlist', label: 'Indent and List',
          buttons: [ 
            { type: 'push', label: 'Indent', value: 'indent', disabled: true }, 
            { type: 'push', label: 'Outdent', value: 'outdent', disabled: true }, 
            { type: 'push', label: 'Create an Unordered List', value: 'insertunorderedlist' }, 
            { type: 'push', label: 'Create an Ordered List', value: 'insertorderedlist' } 
          ]
        }
      ] // buttons:
    } // toolbar:
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

    csrf_protection = jQuery('input[name=authenticity_token]')[0].value
    yuiImgUploader(myEditor, '/image_placements/create_json','uploaded_data', csrf_protection);
    
    var add_stylesheet = function( path){
      var head = this._getDoc().getElementsByTagName('head')[0]; 
      var link = this._getDoc().createElement('link'); 
      link.setAttribute('rel', 'stylesheet'); 
      link.setAttribute('type', 'text/css'); 
      link.setAttribute('href', path); 
      head.appendChild(link); 
    }
    
    myEditor.on('editorContentLoaded', function() { 
      add_stylesheet.call( this, '/stylesheets/blueprint/screen.css');
      add_stylesheet.call( this, '/stylesheets/application.css');
      }, myEditor, true);
        
    myEditor.render();

  ( function( $ ) {
    // put stuff here that needs $ to be jQuery

    })( jQuery );

}); // addLoad