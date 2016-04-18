'use strict';

var comiconServices = angular.module('comiconServices', ['ngResource']);

comiconServices.factory('ComicStrip', ['$resource',
        function($resource) {
            return $resource('strip/:id');
        }
]);

comiconServices.factory('ComicText', [
        function() {
            return {
                position : function(data) {

                    /* position the texts nicely onto the given
                     * area */
                    var mw = $("div#magic").width();
                    var fw = mw / data.texts.length;
                    var fh = $("div#magic").height();
                    var pos_y = fh / data.texts.length;
                    var pos_x = fw / 2;
                    var atpos;
                    var mypos;
                    angular.forEach(data.texts, function(v, k) {
                        var id = 'text-' + k;
                        $('div#texts')
                            .append('<div id="' + id + '" class="textbox">' +
                                    data.texts[k] + '</div>');
                        $('div#' + id)
                            .draggable({
                                stack : '.textbox',
                                stop  : function(event, ui) {
                                    var imagepos = $('div#magic').position();
                                    var topleft  = $(this).offset();
                                    var abs_y    = topleft.top - imagepos.top;
                                    var abs_x    = topleft.left - imagepos.left;
                                    console.log({ top : abs_x, left : abs_y });
                                },
                                containment : 'div#magic'
                            });

                        var w = $("div#" + id).width();
                        var h = $("div#" + id).height();
                        if ( k == 0 ) {
                            /* first frame */
                            atpos = 'left+20 top+20';
                            mypos = 'left top';
                        }
                        else if ( k === data.texts.length - 1 ) {
                            atpos = 'right-20 bottom-20';
                            mypos = 'right bottom';
                        }
                        else {
                            atpos = 'left+' + pos_x.toString() +
                                ' top+' + pos_y.toString();
                            mypos = 'center center';
                        }
                        $("div#" + id).position({
                            my : mypos,
                            at : atpos,
                            of : $("div#magic"),
                            within : 'div#magic',
                            collision : 'fit'
                        });
                        pos_y += fh / ( data.texts.length * 1.1 );
                        pos_x += fw;
                    });
                }
            }
        }
]);
