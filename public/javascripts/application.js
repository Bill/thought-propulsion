Function.prototype.chain = function(args) {
    args.push(this);
    return function() {
     for(var i = 0; i < args.length; i++) {
      args[i]();
     }
    }
   };

var onLoadHandlers = function(){};

// Add an onLoad handler. Don't forget previously added ones.
window.addLoad = function( fn) {
  onLoadHandlers = onLoadHandlers.chain([fn]);
};

google.load("jquery", "1");

google.setOnLoadCallback( function(){ onLoadHandlers();});