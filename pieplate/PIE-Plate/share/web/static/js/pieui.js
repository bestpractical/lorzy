
function lorzy_show_expression_str(str, parent) {
    var el = parent.createAppend('span', { className: 'lorzy-const string' });
    el.html(str)
      .editable(function(value, settings) { alert('yatta'); return value},
                { submit: 'OK' } );
}

function lorzy_show_expression(parent) {

    var ret = parent.createAppend('div', { className: this.name });
    ret.addClass('lorzy-code');
    var that = this;
    jQuery(ret)
    .html(this.name+': '+this.toString() );
//      .click(function () { alert (that.name) });

    jQuery.each(this.args, function(name, exp) {
        console.log(name +  ": "+exp);
        var entry = ret.createAppend('div', { className: that.name+' '+name });
        entry.addClass('lorzy-code-arg');
        jQuery(entry).html(name);
        if (typeof(exp) == 'string') {
            lorzy_show_expression_str(exp, entry);
            return;
        }
        console.log(typeof(exp));
        lorzy_show_expression.apply(exp, [entry]);
    });

}

function lorzy_show(ops) {
    jQuery(ops).each(
        function() {
            lorzy_show_expression.apply(this, [jQuery('#wrapper')]);
        });
};


