
     var lorzy_draggable_opts = { revert: true, activeClass: 'draggable-active', opacity: '0.80'};
var droppable_args = {
            accept: '#wrapper .lorzy-expression',
            greedy: 'true',
            hover: 'pointer',
            activeClass: 'droppable-active',
            hoverClass: 'droppable-hover',
            tolerance: 'pointer',
            drop: function(ev, ui) { 
                    var newitem = jQuery(ui.draggable).clone();
                      var orig = jQuery(ui.draggable); 
                      if (!orig.parent().hasClass('library')) {
                    orig.replaceWith(lorzy_make_empty_drop_target());
                    orig.droppable(droppable_args);

                    }
                    newitem.draggable(lorzy_draggable_opts);
                    newitem.droppable(lorzy_draggable_opts);
                    newitem.attr({style: 'display: block'});
                    newitem.insertAfter(this);
                   lorzy_wrap_in_drop_targets(newitem);
}};









function lorzy_make_empty_drop_target (){

      var x =  jQuery('<div class="lorzy-target"></div>');
      x.droppable(droppable_args);
    return(x);
}
function lorzy_wrap_in_drop_targets(after) {
    
    if(jQuery(after).parent().hasClass('lorzy-target')){
        jQuery(parent).remove(after);
    }
    if(!jQuery(after).prev().hasClass('lorzy-target')){

        jQuery(lorzy_make_empty_drop_target()).insertBefore(after);
        } 

    if(!jQuery(after).next().hasClass('lorzy-target')){
         jQuery(lorzy_make_empty_drop_target()).insertAfter(after);
    }
}




function lorzy_show_expression_str(str, parent) {
    
    var string = jQuery('<div class="lorzy-expression lorzy-const string">'+str+'</div>');
    jQuery(parent).replaceWith(string);

}

function lorzy_show_expression(parent, add_event) {

    if( this.name == 'progn') {
        jQuery.each(this.nodes, function () { lorzy_show_expression(parent) });

        return;
    }

    
    

    var ret = parent.createAppend('div', { className: this.name });
    ret.addClass('lorzy-expression')
    ret.addClass('lorzy-code');
    lorzy_wrap_in_drop_targets(ret);
    var that = this;
    jQuery(ret).createAppend('div', { className: 'name'} , [this.name]);
    var codeargs = jQuery(ret).createAppend('div', { className: 'lorzy-code-args'});

    jQuery.each(this.args, function(name, exp) {
        var entry = codeargs.createAppend('div', { className: that.name+' '+name });
        entry.addClass('lorzy-code-arg');
        entry.createAppend('div', { className: 'name'}, [ name]);
        var value = entry.createAppend('div', { className: 'value'});
        
        if (!exp)
            return;
        if (typeof(exp) == 'string') {
        var valcontent= value.createAppend('div', { className: 'lorzy-expression'});
            lorzy_wrap_in_drop_targets(valcontent);
            lorzy_show_expression_str(exp, valcontent);
            return;
        } else {

        //var progn = valcontent.createAppend('div', { className: 'lorzy-progn'});

        lorzy_show_expression.apply(exp, [value]); //[entry]);

        }
    });

}


function lorzy_show_symbols(struct) {
        jQuery.each(struct, function(item, index) {

        var expression = jQuery('.library').createAppend('div', {className: 'lorzy-expression lorzy-expression-proto'});
        expression.createAppend('div',{className: 'name'},[item]);
        var args_hook = expression.createAppend('div',{className: 'lorzy-code-args'});
        args_hook.createAppend('div', {className: 'lorzy-code-arg'});

        //var args = item;
        jQuery.each(index, function(arg, attr)  { 
                    args_hook.createAppend('div', {className: 'name'}, [arg]);
                    args_hook.createAppend('div', {className: 'type'}, [attr.type]);
                 
        
        });


    });
    jQuery('.library .lorzy-expression').draggable(lorzy_draggable_opts);
}

function lorzy_show(ops) {
    jQuery(ops).each(
        function() {
            lorzy_show_expression.apply(this, [jQuery('#wrapper'), true]);
            
        });
       var tree = lorzy_generate_struct(jQuery('#wrapper'));
        console.log(tree.toJSON());


    jQuery('.lorzy-expression .lorzy-expression').draggable(lorzy_draggable_opts);

    jQuery('#wrapper').after(jQuery('<a>Remove</a>').attr('id', 'remove-entry'));
    jQuery('#wrapper').after(jQuery('<a>Add If</a>').attr('id', 'add-entry-if'));
    jQuery('#wrapper').after(jQuery('<a>Traverse</a>').attr('id', 'clicky'));
    jQuery('#wrapper').after(jQuery('<a>Test</a>').attr('id', 'testy'));

jQuery('#wrapper .lorzy-expression, #wrapper .lorzy-target').droppable(droppable_args);

    jQuery('#testy').click(function () {
        jQuery.ajax({
    'url': '/=/action/Pie.Plate.Action.RunL.xml',
    'datatype': 'text/xml',
    'type': 'post',
    'success': function(xml) { 
            jQuery('#result').append(jQuery(xml).text())
}, 
    'data': 'struct='+lorzy_generate_struct(jQuery('#wrapper')).toJSON()
})


    });

    jQuery('#remove-entry').click(function() {
        var el = jQuery('div.selected');
        if (el.hasClass("value"))
            el.empty();
        else
            el.remove();
        
    });

    jQuery('#add-entry-if').click(function() {
        var el = jQuery('div.selected');
        if (!el.hasClass('value')) {
            el = el.parent();
        }
        lorzy_show_expression.apply({ name: 'IfThen',
                                      args: { if_true: null,
                                              if_false: null,
                                              condition: null
                                            } }, [el, true] );
    });
    
    jQuery('#clicky').click(function () { 
  
 
    var x =  lorzy_generate_struct(jQuery('#wrapper'));
    
    console.log(x.toJSON());
   
   });

};

function lorzy_generate_struct(parent) {

      var ops = jQuery(parent).children();
     var tree=   jQuery.grep( 
         
     
     jQuery.map(ops, function (op) {
        return lorzy_generate_op(jQuery(op));
        }

        ),

        function(element, index) {
                if (element &&  (! jQuery(element).hasClass('lorzy-target'))) {
                return true;
                    } else {
                return false;
                }
        }

    );
   
    return tree;

                    //#lorzy_generate_struct(op)]:

};


function lorzy_generate_op (op) {
            if(op.hasClass('lorzy-target')) {
            // it's nothing. skip it
                return '';

                }
            if (op.hasClass('lorzy-const')) {            
               return op.text();
            } 
           else if( op.hasClass('lorzy-expression')) {
                var codeargs =  op.children('.lorzy-code-args').children();
                return { 'name': op.children('.name').text(), 'args': lorzy_generate_args_struct(codeargs)  };
            } 
            
            else if (op.hasClass('lorzy-progn')) {    
                return { 'progn':  lorzy_generate_progn(op)}; 
            }else  { 
            console.log("failed to find a class on " +op.attr('class'));
            }
}

function lorzy_generate_progn(op) {
        return lorzy_generate_struct(op);//.children('lorzy-expression'));

}


function lorzy_generate_args_struct(args) {

    var myArray = {};
     jQuery.map(args, function (op)  {  
               var values =  lorzy_generate_struct(jQuery(op).children('.value'));
               if (values.length < 1 ) {
                    myArray[ jQuery(op).children('.name').text() ]= null;
                }
               else if (values.length == 1) {
                myArray[ jQuery(op).children('.name').text() ] =   values[0] ;
               } else {
                myArray[ jQuery(op).children('.name').text() ] =  { 'progn': values} ;
               }
    });


    return myArray;
}

