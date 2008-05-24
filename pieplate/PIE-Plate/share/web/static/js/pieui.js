
function lorzy_show_expression_str(str, parent) {
    var el = parent.createAppend('span', { className: 'lorzy-const string' });
    el.html(str)
      .editable(function(value, settings) { alert('yatta'); return value},
                { submit: 'OK' } );
}

function lorzy_show_expression(parent) {

    if( this.name == 'progn') {
        jQuery.each(this.nodes, function () { lorzy_show_expression.apply(this,[parent]) });

        return;
    }

    
    

    var ret = parent.createAppend('div', { className: this.name });
    ret.addClass('lorzy-code');
    var that = this;
    jQuery(ret)
    .html(this.name+': '+this.toString() );
    jQuery(ret).createAppend('div', { className: 'name'} , [this.name]);
    ret = jQuery(ret).createAppend('div', { className: 'lorzy-code-args'});

    jQuery.each(this.args, function(name, exp) {
        console.log(name +  ": "+exp);
        var entry = ret.createAppend('div', { className: that.name+' '+name });
        entry.addClass('lorzy-code-arg');
        entry.createAppend('div', { className: 'name'}, [ name]);
        var value = entry.createAppend('div', { className: 'value'});
        if (typeof(exp) == 'string') {
            lorzy_show_expression_str(exp, value);
            return;
        } else {
        console.log(typeof(exp));
        lorzy_show_expression.apply(exp, [value]); //[entry]);
        }
    });

}

function lorzy_show(ops) {
    jQuery(ops).each(
        function() {
            lorzy_show_expression.apply(this, [jQuery('#wrapper')]);
            
        });
        var tree = lorzy_generate_struct(jQuery('#wrapper'));
        console.log(tree.toJSON());
    jQuery('#wrapper').after(jQuery('<a href="#">Traverse</a>').attr('id', 'clicky'));
    
   jQuery('#clicky').click(function () { 
   
    var x =  lorzy_generate_struct(jQuery('#wrapper'));
    
    console.log(x.toJSON());
   
   });
};

function lorzy_generate_struct(parent) {

      var ops = jQuery(parent).children();
     var tree=    jQuery.map(ops, function (op) {
            return lorzy_generate_op(jQuery(op));
       }

        );
   
    return tree;

                    //#lorzy_generate_struct(op)]:

};


function lorzy_generate_op (op) {
    
            if( op.hasClass('lorzy-code')) {
                
                var codeargs =  op.children('.lorzy-code-args').children();
                return { 'name': op.children('.name').text(), 'args': lorzy_generate_args_struct(codeargs)  };
            } else if (op.hasClass('lorzy-const')) {            
               return op.text();
            }else  { 
            console.log("failed to find a class on " +op.attr('class'));
            }
}


function lorzy_generate_args_struct(args) {
    var myArray = {};
     jQuery.map(args, function (op)  {  
               var kids = lorzy_generate_struct(jQuery(op).children('.value'));
               if (kids.length == 1) {
                myArray[ jQuery(op).children('.name').text() ] =   kids[0] ;
               } else {
                myArray[ jQuery(op).children('.name').text() ] =  { 'progn': kids} ;
               }
    });


    return myArray;
}

