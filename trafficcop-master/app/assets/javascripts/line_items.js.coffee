# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$(document).ready ->
  $( "#start_time" ).datepicker({showButtonPanel: true, dateFormat: 'yy-mm-dd', minDate: 1});
  $( "#end_time" ).datepicker({showButtonPanel: true, dateFormat: 'yy-mm-dd', minDate: 1});

availableTags = ["Cube (300X250)", "Spw Promo Ad (240X470)", "Leaderboard (728X90)"];

split = (val) ->  val.split( /,\s*/ );
extractLast = (term) -> split( term ).pop(); 
 
source_function = (request, response) ->
  response( $.ui.autocomplete.filter(
    availableTags, extractLast( request.term ) ) ); 

$(document).ready ->
  $( "#line_item_inventory_sizes").bind( "keydown", ( event ) -> 
    if event.keyCode is $.ui.keyCode.TAB &&
       $(this).data( "autocomplete" ).menu.active 
          event.preventDefault();
       
    ).autocomplete({
      minLength: 0,
      source: ( request, response ) -> 
        response( $.ui.autocomplete.filter(
          availableTags, extractLast( request.term ) ) );
      , focus: () -> 
        return false;
      , select: ( event, ui ) ->
        terms = split( this.value );
        terms.pop();
        terms.push( ui.item.value );
        terms.push( "" );
        this.value = terms.join( ", " );
        return false;
        });
